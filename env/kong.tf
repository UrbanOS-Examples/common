data "template_file" "kong_config" {
  template = "${file("${path.module}/files/kong/kong.conf.tpl")}"

  vars {
    DB_HOST     = "${aws_db_instance.kong.address}"
    DB_PORT     = "${aws_db_instance.kong.port}"
    DB_PASSWORD = "${random_string.kong_db_password_kong.result}"
  }
}

resource "aws_instance" "kong" {
  instance_type          = "${var.kong_instance_type}"
  ami                    = "${var.kong_backup_ami}"
  vpc_security_group_ids = ["${aws_security_group.os_servers.id}"]
  ebs_optimized          = "${var.kong_instance_ebs_optimized}"
  iam_instance_profile   = "${var.kong_instance_profile}"
  subnet_id              = "${module.vpc.public_subnets[0]}"
  key_name               = "${aws_key_pair.cloud_key.key_name}"

  tags {
    Name    = "${terraform.workspace} kong"
    BaseAMI = "${var.kong_backup_ami}"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }

  provisioner "file" {
    content     = "${data.template_file.kong_config.rendered}"
    destination = "/tmp/kong.conf"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "centos"
    }
  }

  provisioner "file" {
    source     = "${path.module}/files/kong/setup.sh"
    destination = "/tmp/setup.sh"

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
  --db-host ${aws_db_instance.kong.address} \
  --db-port ${aws_db_instance.kong.port} \
  --db-admin-password ${random_string.kong_db_password_sysadmin.result} \
  --db-kong-password ${random_string.kong_db_password_kong.result} \
  --ckan-internal-url http://${aws_route53_record.ckan_internal_ec2_record.fqdn}/ \
  --kong-host ${aws_route53_record.kong_public_dns.fqdn}
EOF
    ]

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "centos"
    }
  }
}

resource "aws_alb_target_group_attachment" "kong_private" {
  target_group_arn = "${module.load_balancer_private.target_group_arns["${terraform.workspace}-Int-Kong"]}"
  target_id        = "${aws_instance.kong.id}"
  port             = 80
}

resource "aws_route53_record" "kong_public_dns" {
  zone_id = "${aws_route53_zone.public_hosted_zone.zone_id}"
  name    = "api"
  type    = "A"
  count   = 1

  alias {
    name                   = "${module.load_balancer_private.dns_name}"
    zone_id                = "${module.load_balancer_private.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_db_instance" "kong" {
  identifier             = "${terraform.workspace}-${var.kong_db_identifier}"
  instance_class         = "${var.kong_db_instance_class}"
  vpc_security_group_ids = ["${aws_security_group.os_servers.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.default.name}"
  skip_final_snapshot    = true
  engine                 = "postgres"
  engine_version         = "9.6.6"
  parameter_group_name   = "${var.kong_db_parameter_group_name}"
  allocated_storage      = "${var.kong_db_allocated_storage}"
  storage_type           = "gp2"
  username               = "sysadmin"
  password               = "${random_string.kong_db_password_sysadmin.result}"
  snapshot_identifier    = "${var.kong_db_snapshot_id}"
  multi_az               = "${var.kong_db_multi_az}"
  storage_encrypted      = false
  iops                   = 0

  tags {
    workload-type = "${terraform.workspace}"
  }

  lifecycle {
    ignore_changes = ["final_snapshot_identifier", "storage_encrypted", "snapshot_identifier"]
  }
}

resource "random_string" "kong_db_password_sysadmin" {
  length = 40
  special = false
}

resource "random_string" "kong_db_password_kong" {
  length = 40
  special = false
}

variable "kong_backup_ami" {
  description = "The AMI to restore for kong"
}

variable "kong_db_snapshot_id" {
  description = "The snapshot to restore for the kong db"
}

variable "kong_db_multi_az" {
  description = "is ckan rds db multi az?"
  default = false
}

variable "kong_db_parameter_group_name" {
  description = "The aws parameter group for the kong db"
  default     = "default.postgres9.6"
}

variable "kong_db_allocated_storage" {
  description = "How much storage is allocated for the kong db"
  default     = 100
}

variable "kong_instance_ebs_optimized" {
  description = "Whether or not the kong external server is EBS optimized"
  default     = false
}

variable "kong_db_identifier" {
  description = "AWS RDS identifier for kong db instance"
  default     = "kong"
}

variable "kong_db_instance_class" {
  description = "The size of the instance for the kong database"
  default     = "db.m4.large"
}

variable "kong_instance_profile" {
  description = "Instance Profile for kong server"
  default     = ""

  //TODO: Create CloudWatch_EC2 in Terraform
  //default     = "CloudWatch_EC2"
}

variable "kong_instance_type" {
  description = "Instance type for kong server"
  default     = "t2.small"
}

output "kong_instance_id" {
  value = "${aws_instance.kong.id}"
}
