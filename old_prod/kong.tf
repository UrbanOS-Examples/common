resource "aws_instance" "kong" {
  instance_type          = "${var.kong_instance_type}"
  ami                    = "${var.kong_ami}"
  vpc_security_group_ids = ["${data.aws_security_group.scos_servers.id}"]
  ebs_optimized          = "${var.kong_instance_ebs_optimized}"
  iam_instance_profile   = "${var.kong_instance_profile}"
  key_name               = "${var.kong_keypair_name}"

  tags {
    Name    = "kong"
    BaseAMI = "${var.kong_ami}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's#pg_host =.*#pg_host = ${aws_db_instance.kong.address}#' /etc/kong/kong.conf",
    ]

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "centos"

      bastion_host = "${local.bastion_host}"
      bastion_user = "centos"
    }
  }
}

resource "aws_alb_target_group_attachment" "kong_private" {
  target_group_arn = "${module.load_balancer_private.target_group_arns["${var.target_group_prefix}-Internal-Kong"]}"
  target_id        = "${aws_instance.kong.id}"
  port             = 80
}

resource "aws_alb_target_group_attachment" "kong_public" {
  target_group_arn = "${module.load_balancer_public.target_group_arns["${var.target_group_prefix}-Kong"]}"
  target_id        = "${aws_instance.kong.id}"
  port             = 80
}

resource "aws_route53_record" "kong_private_dns" {
  zone_id = "${aws_route53_zone.private_hosted_zone.zone_id}"
  name    = "kong"
  type    = "A"
  count   = 1
  ttl     = 300
  records = ["${aws_instance.kong.private_ip}"]
}

resource "aws_route53_record" "kong_public_dns" {
  zone_id = "${local.public_zone_id}"
  name    = "api"
  type    = "A"
  count   = 1

  alias {
    name                   = "${module.load_balancer_public.dns_name}"
    zone_id                = "${module.load_balancer_public.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "kong_alm_dns" {
  provider = "aws.alm"
  zone_id  = "${local.alm_private_zone_id}"
  name     = "api.${terraform.workspace}"
  type     = "A"
  count    = 1

  alias {
    name                   = "${module.load_balancer_private.dns_name}"
    zone_id                = "${module.load_balancer_private.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_db_instance" "kong" {
  identifier             = "${var.kong_db_identifier}"
  instance_class         = "${var.kong_db_instance_class}"
  vpc_security_group_ids = ["${data.aws_security_group.scos_servers.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.default.name}"
  skip_final_snapshot    = true
  engine                 = "postgres"
  engine_version         = "9.6.6"
  parameter_group_name   = "${var.kong_db_parameter_group_name}"
  allocated_storage      = "${var.kong_allocated_storage}"
  storage_type           = "io1"
  username               = "sysadmin"
  password               = "${var.kong_db_password}"
  snapshot_identifier    = "${var.kong_rds_snapshot_id}"
  multi_az               = "${var.rds_multi_az}"
  storage_encrypted      = false
  iops                   = 1000

  tags {
    workload-type = "production"
  }

  lifecycle {
    ignore_changes = ["snapshot_identifier"]
  }
}

variable "kong_ami" {
  description = "The AMI to restore for kong"
}

variable "kong_rds_snapshot_id" {
  description = "The snapshot to restore for the kong db"
  default     = ""
}

variable "rds_multi_az" {
  description = "Are RDS instances hosted accross multiple AZs (boolean)"
  default     = true
}

variable "kong_db_parameter_group_name" {
  description = "The aws parameter group for the kong db"
  default     = "default.postgres9.6"
}

variable "kong_allocated_storage" {
  description = "How much storage is allocated for the kong db"
  default     = 100
}

variable "kong_db_password" {
  description = "AWS RDS identifier for kong db instance"
}

variable "kong_instance_ebs_optimized" {
  description = "Whether or not the kong external server is EBS optimized"
  default     = true
}

variable "kong_db_identifier" {
  description = "AWS RDS identifier for kong db instance"
  default     = "prod-kong-0-13-1"
}

variable "kong_db_instance_class" {
  description = "The size of the instance for the kong database"
  default     = "db.m4.large"
}

variable "kong_instance_profile" {
  description = "Instance Profile for kong server"
  default     = "CloudWatch_EC2"
}

variable "kong_keypair_name" {
  description = "The name of the keypair for ssh authentication"
  default     = "Prod_Kong_Key_Pair"
}

variable "kong_instance_type" {
  description = "Instance type for kong server"
  default     = "m4.2xlarge"
}
