data "template_file" "ckan_internal_config" {
  template = "${file("${path.module}/files/ckan/production.ini.tpl")}"

  vars {
    DB_CKAN_PASSWORD = "${random_string.ckan_db_password_ckan.result}"
    DB_DATASTORE_PASSWORD = "${random_string.ckan_db_password_datastore.result}"
    DB_HOST = "${aws_db_instance.ckan.address}"
    DB_PORT = "${aws_db_instance.ckan.port}"
    DNS_ZONE = "${terraform.workspace}.${var.root_dns_zone}"
    SOLR_HOST = "${aws_instance.ckan_external.private_ip}"
    REDIS_HOST = "${aws_instance.ckan_external.private_ip}"
    S3_BUCKET = "${aws_s3_bucket.ckan.id}"
    EXTRA_PLUGINS = ""
  }
}

resource "aws_instance" "ckan_internal" {
  instance_type          = "${var.ckan_internal_instance_type}"
  ami                    = "${var.ckan_internal_backup_ami}"
  vpc_security_group_ids = ["${aws_security_group.os_servers.id}"]
  ebs_optimized          = "${var.ckan_internal_instance_ebs_optimized}"
  iam_instance_profile   = "${var.ckan_internal_instance_profile}"
  subnet_id              = "${module.vpc.public_subnets[0]}"
  key_name               = "${aws_key_pair.cloud_key.key_name}"
  iam_instance_profile   = "${aws_iam_instance_profile.ckan.name}"

  depends_on = ["aws_instance.ckan_external", "aws_db_instance.ckan"]

  tags {
    Name    = "${terraform.workspace} CKAN Internal"
    BaseAMI = "${var.ckan_internal_backup_ami}"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }

  provisioner "file" {
    source     = "${path.module}/files/ckan/setup.sh"
    destination = "/tmp/setup.sh"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "ubuntu"
    }
  }

  provisioner "file" {
    source     = "${path.module}/files/ckan/ckan-2.8.sh"
    destination = "/tmp/upgrade.sh"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "ubuntu"
    }
  }

  provisioner "file" {
    source = "${path.module}/files/ckan/update-aws-credentials.sh"
    destination = "/tmp/update-aws-credentials.sh"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "ubuntu"
    }
  }

  provisioner "file" {
    content = "${data.template_file.ckan_internal_config.rendered}"
    destination = "/tmp/production.ini"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "ubuntu"
    }
  }

  provisioner "file" {
    source = "${path.module}/files/ckan/nginx-internal.conf"
    destination = "/tmp/nginx.conf"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "ubuntu"
    }
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
sudo bash /tmp/setup.sh \
  --db-host ${aws_db_instance.ckan.address} \
  --db-port ${aws_db_instance.ckan.port} \
  --db-admin-password ${random_string.ckan_db_password_sysadmin.result} \
  --db-ckan-password ${random_string.ckan_db_password_ckan.result} \
  --db-datastore-password ${random_string.ckan_db_password_datastore.result} \
  --s3-bucket-region ${aws_s3_bucket.ckan.region}
EOF
    ]

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "ubuntu"
    }
  }
}

resource "aws_iam_policy_attachment" "ckan_rds_monitoring" {
  name = "ckan_rds_monitoring"
  roles = ["${aws_iam_role.ckan_rds_monitoring.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_route53_record" "ckan_internal_ec2_record" {
  zone_id = "${aws_route53_zone.public_hosted_zone.zone_id}"
  name    = "ckan-internal"
  type    = "A"
  count   = 1
  ttl     = 300
  records = ["${aws_instance.ckan_internal.private_ip}"]
}

variable "ckan_internal_instance_ebs_optimized" {
  description = "Whether or not the CKAN internal server is EBS optimized"
  default     = true
}

variable "ckan_internal_instance_profile" {
  description = "Instance Profile for ckan_internal server"
  default     = "CloudWatch_EC2"
}

variable "ckan_internal_instance_type" {
  description = "Instance type for ckan_internal server"
  default     = "m4.2xlarge"
}

variable "ckan_internal_backup_ami" {
  description = "AMI to restore ckan_internal from"
}

