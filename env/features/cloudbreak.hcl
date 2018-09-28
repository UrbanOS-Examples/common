
resource "aws_kms_key" "cloudbreak_db_key" {
  description             = "cloudbreak db encryption key for ${terraform.workspace}"
}

resource "aws_kms_alias" "cloudbreak_db_key_alias" {
  name_prefix           = "alias/cloudbreak"
  target_key_id         = "${aws_kms_key.cloudbreak_db_key.key_id}"
}

resource "random_string" "cloudbreak_db_password" {
  length = 40
  special = false
}

resource "aws_db_subnet_group" "cloudbreak_db_subnet_group" {
  name        = "cloudbreak db ${terraform.workspace} subnet group"
  description = "DB Subnet Group"
  subnet_ids  = ["${module.vpc.private_subnets}"]

  tags {
    Name = "Subnet Group for Cloudbreak in Environment ${terraform.workspace} VPC"
  }
}

resource "aws_security_group" "cloudbreak_security_group" {
  name   = "Cloudbreak Security Group"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow traffic from self"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.terraform_remote_state.alm_remote_state.vpc_cidr_block}"]
    description = "Allow all traffic from admin VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "cloudbreak_db" {
  identifier              = "${terraform.workspace}-cloudbreak"
  instance_class          = "db.t2.small"
  vpc_security_group_ids  = ["${aws_security_group.cloudbreak_security_group.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.cloudbreak_db_subnet_group.name}"
  engine                  = "postgres"
  engine_version          = "10.4"
  allocated_storage       = 100 # The allocated storage in gibibytes.
  storage_type            = "gp2"
  username                = "cloudbreak"
  password                = "${random_string.cloudbreak_db_password.result}"
  multi_az                = "${var.cloudbreak_db_multi_az}"
  backup_window           = "04:54-05:24"
  backup_retention_period = 7
  storage_encrypted       = true
  kms_key_id              = "${aws_kms_key.cloudbreak_db_key.arn}"
  apply_immediately       = "${var.cloudbreak_db_apply_immediately}"

  lifecycle = {
    prevent_destroy = true
  }
}

// if this changes, there is a chance that deployed clusters will be orphaned
resource "random_string" "cloudbreak_cluster_secret" {
  length = 40
  special = false
}

resource "random_string" "cloudbreak_admin_password" {
  length = 40
  special = false
}

data "template_file" "cloudbreak_profile" {
  template = "${file("${path.module}/files/cloudbreak/Profile.tpl")}"

  vars {
    UAA_DEFAULT_SECRET="${random_string.cloudbreak_cluster_secret.result}"
    UAA_DEFAULT_USER_PW="${random_string.cloudbreak_admin_password.result}"
    UAA_DEFAULT_USER_EMAIL="admin@smartcolumbusos.com"
    PUBLIC_IP="cloudbreak.${aws_route53_zone.public_hosted_zone.name}"

    DATABASE_HOST="${aws_db_instance.cloudbreak_db.address}"
    DATABASE_PORT="${aws_db_instance.cloudbreak_db.port}"
    DATABASE_USERNAME="cloudbreak"
    DATABASE_PASSWORD="${random_string.cloudbreak_db_password.result}"
  }
}

data "aws_ami" "cloudbreak" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-aws-ebs-*"]
  }

  tags = [
    {
      key   = "promotion-tag",
      value = "${var.cloudbreak_tag}"
    },
    {
      key   = "cloudbreak-version",
      value = "2.7.1"
    }
  ]

  owners = [
    "068920858268",
    "199837183662"
  ]
}

resource "random_shuffle" "private_subnet" {
  input   = ["${module.vpc.private_subnets}"]
  keepers = {
    private_subnets = "${join(",", module.vpc.private_subnets)}"
  }
}

resource "aws_instance" "cloudbreak" {
  instance_type          = "t2.xlarge"
  ami                    = "${data.aws_ami.cloudbreak.id}"
  vpc_security_group_ids = ["${aws_security_group.cloudbreak_security_group.id}"]
  ebs_optimized          = "false"
  subnet_id              = "${random_shuffle.private_subnet.result[0]}"
  key_name               = "${aws_key_pair.cloud_key.key_name}"
  iam_instance_profile   = "${aws_iam_instance_profile.cloudbreak.name}"

  tags {
    Name    = "${terraform.workspace} Cloudbreak"
    BaseAMI = "${data.aws_ami.cloudbreak.id}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "cloudbreak" {
  triggers {
    instance_updated = "${aws_instance.cloudbreak.id}"
    profile_updated  = "${sha1(data.template_file.cloudbreak_profile.rendered)}"
    setup_updated    = "${sha1(file("${path.module}/files/cloudbreak/setup.sh"))}"
  }

  connection {
    type = "ssh"
    host = "${aws_instance.cloudbreak.private_ip}"
    user = "ec2-user"
  }

  provisioner "file" {
    //newline included here because Cloudbreak appends to the end of this file
    content = "${data.template_file.cloudbreak_profile.rendered}\n"
    destination = "/tmp/Profile"
  }

  provisioner "file" {
    source = "${path.module}/files/cloudbreak/setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x /tmp/setup.sh && sudo /tmp/setup.sh"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_target_group_attachment" "cloudbreak_private" {
  target_group_arn = "${aws_alb_target_group.cloudbreak.arn}"
  target_id        = "${aws_instance.cloudbreak.id}"
  port             = 443

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ "null_resource.cloudbreak" ]
}

resource "aws_route53_record" "cloudbreak_public_dns" {
  zone_id = "${aws_route53_zone.public_hosted_zone.zone_id}"
  name    = "cloudbreak"
  type    = "A"

  alias {
    name                   = "${aws_alb.cloudbreak.dns_name}"
    zone_id                = "${aws_alb.cloudbreak.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_iam_instance_profile" "cloudbreak" {
  name = "${terraform.workspace}_cloudbreak"
  role = "${aws_iam_role.cloudbreak_ec2.name}"
}

resource "aws_iam_role" "cloudbreak_ec2" {
  name = "${terraform.workspace}_cloudbreak_ec2"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
}
EOF
}

resource "aws_iam_role_policy" "cloudbreak_role_assumption" {
  name = "cloudbreak_role_assumption_policy"
  role = "${aws_iam_role.cloudbreak_ec2.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Sid": "AssumeDefaultCredentialRole",
        "Effect": "Allow",
        "Action": ["sts:AssumeRole"],
        "Resource": "*"
    }
}
EOF
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "cloudbreak_credential" {
  name = "${terraform.workspace}_cloudbreak_credential"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                ]
            },
            "Action": "sts:AssumeRole",
            "Condition": {}
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "cloudbreak_credential" {
  name = "cloudbreak_credential_policy"
  role = "${aws_iam_role.cloudbreak_credential.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStackEvents",
                "cloudformation:DescribeStackResource",
                "cloudformation:DescribeStacks"
            ],
            "Resource": [
                "*"
            ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:AllocateAddress",
            "ec2:AssociateAddress",
            "ec2:AssociateRouteTable",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:DescribeRegions",
            "ec2:DescribeAvailabilityZones",
            "ec2:CreateRoute",
            "ec2:CreateRouteTable",
            "ec2:CreateSecurityGroup",
            "ec2:CreateSubnet",
            "ec2:CreateTags",
            "ec2:CreateVpc",
            "ec2:ModifyVpcAttribute",
            "ec2:DeleteSubnet",
            "ec2:CreateInternetGateway",
            "ec2:CreateKeyPair",
            "ec2:DeleteKeyPair",
            "ec2:DisassociateAddress",
            "ec2:DisassociateRouteTable",
            "ec2:ModifySubnetAttribute",
            "ec2:ReleaseAddress",
            "ec2:DescribeAddresses",
            "ec2:DescribeImages",
            "ec2:DescribeInstanceStatus",
            "ec2:DescribeInstances",
            "ec2:DescribeInternetGateways",
            "ec2:DescribeKeyPairs",
            "ec2:DescribeRouteTables",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcs",
            "ec2:DescribeSpotInstanceRequests",
            "ec2:DescribeVpcAttribute",
            "ec2:ImportKeyPair",
            "ec2:AttachInternetGateway",
            "ec2:DeleteVpc",
            "ec2:DeleteSecurityGroup",
            "ec2:DeleteRouteTable",
            "ec2:DeleteInternetGateway",
            "ec2:DeleteRouteTable",
            "ec2:DeleteRoute",
            "ec2:DetachInternetGateway",
            "ec2:RunInstances",
            "ec2:StartInstances",
            "ec2:StopInstances",
            "ec2:TerminateInstances"
          ],
          "Resource": [
            "*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "iam:ListRolePolicies",
            "iam:GetRolePolicy",
            "iam:ListAttachedRolePolicies",
            "iam:ListInstanceProfiles",
            "iam:PutRolePolicy",
            "iam:PassRole",
            "iam:GetRole"
          ],
          "Resource": [
            "*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "autoscaling:CreateAutoScalingGroup",
            "autoscaling:CreateLaunchConfiguration",
            "autoscaling:DeleteAutoScalingGroup",
            "autoscaling:DeleteLaunchConfiguration",
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeScalingActivities",
            "autoscaling:DetachInstances",
            "autoscaling:ResumeProcesses",
            "autoscaling:SuspendProcesses",
            "autoscaling:UpdateAutoScalingGroup"
          ],
          "Resource": [
            "*"
          ]
        }
    ]
}
EOF
}

resource "aws_alb" "cloudbreak" {
  name = "cloudbreak-lb-${terraform.workspace}"
  load_balancer_type = "application"
  internal = true
  subnets = ["${module.vpc.private_subnets}"]
  security_groups = ["${aws_security_group.cloudbreak_security_group.id}"]
}

resource "aws_alb_target_group" "cloudbreak" {
  name = "cloudbreak-lb-tg-${terraform.workspace}"
  port = 443
  protocol = "HTTPS"
  vpc_id = "${module.vpc.vpc_id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/cb/info"
    protocol            = "HTTPS"
    matcher             = "200"
    port                = 443
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.cloudbreak.arn}"
  certificate_arn   = "${module.tls_certificate.arn}"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.cloudbreak.arn}"
  }
}

variable "cloudbreak_db_multi_az" {
  description = "Should the Cloudbreak DB be multi-az?"
  default     = true
}

variable "cloudbreak_db_apply_immediately" {
  description = "Should changes to the Cloudbreak DB be applied immediately?"
  default = false
}

variable "cloudbreak_tag" {
  description = "The released version of a Cloudbreak AMI to use"
  default = "1.0.0"
}