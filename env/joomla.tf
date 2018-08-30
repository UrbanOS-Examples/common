data "template_file" "joomla_unite_config" {
  template = "${file("${path.module}/files/joomla/joomla_unite_config.xml.tpl")}"

  vars {
    JOOMLA_ADMIN_EMAIL = "smartcolumbusos@columbus.gov"
    JOOMLA_SITE_URL    = "https://www.smartcolumbusos.com/"
    JOOMLA_DB_HOST     = "${aws_db_instance.joomla_db.address}"
    JOOMLA_DB_USER     = "${aws_db_instance.joomla_db.username}"
    JOOMLA_DB_PASSWORD = "${random_string.joomla_db_password.result}"
  }
}

resource "aws_db_instance" "joomla_db" {
  identifier             = "${var.joomla_db_identifier}-${terraform.workspace}"
  instance_class         = "db.t2.large"
  vpc_security_group_ids = ["${aws_security_group.os_servers.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.default.name}"
  skip_final_snapshot    = true
  engine                 = "mysql"
  engine_version         = "5.6.37"
  parameter_group_name   = "default.mysql5.6"
  allocated_storage      = 100
  storage_type           = "gp2"
  username               = "joomla"
  password               = "${random_string.joomla_db_password.result}"

  tags {
    workload-type = "other"
  }
}

resource "aws_security_group" "os_servers" {
  name   = "OS Servers"
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

resource "aws_security_group" "os_external_access" {
  name   = "SCOS External Access"
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "os_external_access_egress_rule" {
  type = "egress"
  from_port=0
  to_port=0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
  security_group_id = "${aws_security_group.os_external_access.id}"
}

resource "aws_db_subnet_group" "default" {
  name        = "environment db ${terraform.workspace} subnet group"
  description = "DB Subnet Group"
  subnet_ids  = ["${module.vpc.private_subnets}"]

  tags {
    Name = "Subnet Group for Environment ${terraform.workspace} VPC"
  }
}
resource "aws_iam_instance_profile" "joomla" {
  name = "joomla"
  role = "${aws_iam_role.joomla_ec2.name}"
}

resource "aws_iam_role" "joomla_ec2" {
  name = "joomla_ec2"
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
            "Effect": "Allow",
            "Sid": "${terraform.workspace}-joomla-instance-role"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "joomla_s3_bucket_policy" {
  name = "joomla_s3_bucket_policy"
  role = "${aws_iam_role.joomla_ec2.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": ["${aws_s3_bucket.joomla-backups.arn}/*"]
      "Sid": "${terraform.workspace}-joomla-s3-bucket-access"
    }
  ]
}
EOF
}

resource "aws_instance" "joomla" {
  instance_type          = "${var.joomla_instance_type}"
  ami                    = "${var.joomla_backup_ami}"
  vpc_security_group_ids = ["${aws_security_group.os_servers.id}"]
  ebs_optimized          = "${var.joomla_instance_ebs_optimized}"
  iam_instance_profile   = "${var.joomla_instance_profile}"
  subnet_id              = "${module.vpc.public_subnets[0]}"
  key_name               = "${aws_key_pair.cloud_key.key_name}"
  iam_instance_profile   = "${aws_iam_instance_profile.joomla.name}"

  tags {
    Name    = "${terraform.workspace} Joomla"
    BaseAMI = "${var.joomla_backup_ami}"
  }

  provisioner "file" {
    content     = "${data.template_file.joomla_unite_config.rendered}"
    destination = "/tmp/scos_unite.xml"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "centos"
    }
  }

  provisioner "file" {
    source     = "${path.module}/files/joomla/doJoomlaBackup.sh"
    destination = "/home/centos/doJoomlaBackup.sh"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "centos"
    }
  }


  provisioner "file" {
    source     = "${path.module}/files/joomla/setup.sh"
    destination = "/tmp/setup.sh"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "centos"
    }
  }


  provisioner "file" {
    source      = "${path.module}/files/joomla/unite.phar"
    destination = "/tmp/unite.phar"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "centos"
    }
  }

  provisioner "file" {
    source      = "${path.module}/files/joomla/nginx.conf"
    destination = "/tmp/joomla_nginx.conf"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "centos"
    }
  }

  provisioner "file" {
    source      = "${path.module}/files/joomla/httpd.conf"
    destination = "/tmp/joomla_httpd.conf"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "centos"
    }
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
sudo bash /tmp/setup.sh \
  --db-host ${aws_db_instance.joomla_db.address} \
  --db-password ${random_string.joomla_db_password.result} \
  --db-user ${aws_db_instance.joomla_db.username} \
  --s3-bucket ${aws_s3_bucket.joomla-backups.id} \
  --s3-path '${var.joomla_backup_file_name}' \
  --dns-zone '${terraform.workspace}.${var.root_dns_zone}'
EOF
    ]

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "centos"
    }
  }
}

resource "aws_s3_bucket" "joomla-backups" {
  bucket = "${terraform.workspace}-os-joomla-backups"
  acl    = "private"

  provisioner "local-exec" {
    command = "aws s3 cp s3://${data.terraform_remote_state.durable.smart_os_initial_state_bucket_name}/${var.joomla_backup_file_name} s3://${self.id}/${var.joomla_backup_file_name}"
  }
}

resource "aws_lb_target_group_attachment" "joomla_private" {
  target_group_arn = "${module.load_balancer_private.target_group_arns["${terraform.workspace}-Int-Joomla"]}"
  target_id        = "${aws_instance.joomla.id}"
  port             = 80
}

resource "aws_lb_target_group_attachment" "joomla_public" {
  target_group_arn = "${module.load_balancer_public.target_group_arns["${terraform.workspace}-Joomla"]}"
  target_id        = "${aws_instance.joomla.id}"
  port             = 80
}

resource "aws_route53_record" "joomla_public_dns" {
  zone_id = "${aws_route53_zone.public_hosted_zone.zone_id}"
  name    = ""
  type    = "A"
  count   = 1

  alias {
    name                   = "${module.load_balancer_private.dns_name}"
    zone_id                = "${module.load_balancer_private.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "joomla_www_public_dns" {
  zone_id = "${aws_route53_zone.public_hosted_zone.zone_id}"
  name    = "www"
  type    = "A"
  count   = 1

  alias {
    name                   = "${module.load_balancer_private.dns_name}"
    zone_id                = "${module.load_balancer_private.zone_id}"
    evaluate_target_health = false
  }
}

resource "random_string" "joomla_db_password" {
  length = 40
  special = false
}

variable "joomla_backup_file_name" {
  description = "Name of the Akeeba backup file in the backup S3 bucket"
}

variable "joomla_db_identifier" {
  description = "AWS RDS identifier for joomla db instance"
  default     = "joomla"
}

variable "joomla_instance_ebs_optimized" {
  description = "Whether or not the Joomla server is EBS optimized"
  default     = true
}

variable "joomla_instance_profile" {
  description = "Instance Profile for Joomla server"
  default     = ""
  //TODO: Create CloudWatch_EC2 in Terraform
  //default     = "CloudWatch_EC2"
}

variable "joomla_instance_type" {
  description = "Instance type for Joomla server"
  default     = "m4.2xlarge"
}

variable "joomla_backup_ami" {
  description = "AMI to restore Joomla from"
}