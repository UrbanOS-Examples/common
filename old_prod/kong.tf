resource "aws_instance" "kong" {
  instance_type          = "${var.kong_instance_type}"
  ami                    = "${var.kong_ami}"
  vpc_security_group_ids = ["${data.aws_security_group.scos_servers.id}"]
  ebs_optimized          = "${var.kong_instance_ebs_optimized}"
  iam_instance_profile   = "${var.kong_instance_profile}"
  subnet_id              = "${data.aws_subnet.subnet.1.id}"

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

resource "aws_alb_target_group_attachment" "kong_internal" {
  target_group_arn = "${module.load_balancer.target_group_arns["${var.target_group_prefix}-Internal-Kong"]}"
  target_id        = "${aws_instance.kong.id}"
  port             = 80
}

resource "aws_alb_target_group_attachment" "kong_external" {
  count            = "${var.alb_external}"
  target_group_arn = "${module.load_balancer_external.target_group_arns["${var.target_group_prefix}-Kong"]}"
  target_id        = "${aws_instance.kong.id}"
  port             = 80
}

resource "aws_route53_record" "kong_dns" {
  zone_id = "${aws_route53_zone.private_hosted_zone.zone_id}"
  name    = "kong"
  type    = "A"
  count   = 1
  ttl     = "300"
  records = ["${aws_instance.kong.private_ip}"]
}

resource "aws_db_instance" "kong" {
  identifier             = "${var.kong_db_identifier}"
  instance_class         = "${var.kong_db_instance_class}"
  vpc_security_group_ids = ["${data.aws_security_group.scos_servers.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.default.name}"
  skip_final_snapshot    = true
  engine                 = "postgres"
  engine_version         = "${var.kong_engine_version}"
  parameter_group_name   = "${var.kong_db_parameter_group_name}"
  allocated_storage      = "${var.kong_allocated_storage}"
  storage_type           = "gp2"
  username               = "Sysadmin"
  password               = "${var.kong_db_password}"
  snapshot_identifier    = "${var.kong_rds_snapshot_id}"
  multi_az               = "${var.rds_multi_az}"
  storage_encrypted      = true

  tags {
    workload-type = "other"
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
}

variable "rds_multi_az" {
  description = "Are RDS instances hosted accross multiple AZs (boolean)"
}

variable "kong_engine_version" {
  description = "Engine version of kong"
}

variable "kong_db_parameter_group_name" {
  description = "The aws parameter group for the kong db"
}

variable "kong_allocated_storage" {
  description = "How much storage is allocated for the kong db"
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
}

variable "kong_db_instance_class" {
  description = "The size of the instance for the kong database"
}

variable "kong_instance_profile" {
  description = "Instance Profile for kong server"
  default     = "CloudWatch_EC2"
}

variable "kong_instance_type" {
  description = "Instance type for kong server"
  default     = "m4.2xlarge"
}
