data "template_file" "ckan_external_config" {
  template = "${file("${path.module}/files/ckan/production.ini.tpl")}"

  vars {
    DB_CKAN_PASSWORD = "${random_string.ckan_db_password_ckan.result}"
    DB_DATASTORE_PASSWORD = "${random_string.ckan_db_password_datastore.result}"
    DB_HOST = "${aws_db_instance.ckan.address}"
    DB_PORT = "${aws_db_instance.ckan.port}"
    DNS_ZONE = "${local.ckan_dns_zone}"
    SOLR_HOST = "127.0.0.1"
    REDIS_HOST = "127.0.0.1"
    S3_BUCKET = "${aws_s3_bucket.ckan.id}"
    EXTRA_PLUGINS = "scos_theme"
    AWS_ACCESS_KEY_ID = "${aws_iam_access_key.s3_serviceaccount_credentials.id}"
    AWS_SECRET_ACCESS_KEY = "${aws_iam_access_key.s3_serviceaccount_credentials.secret}"
  }
}

data "template_file" "ckan_external_nginx_config" {
  template = "${file("${path.module}/files/ckan/nginx-external.conf.tpl")}"

  vars {
    DNS_ZONE = "${coalesce("${var.prod_dns_zone}","${terraform.workspace}.${var.root_dns_zone}")}"
  }
}

resource "aws_instance" "ckan_external" {
  instance_type          = "${var.ckan_external_instance_type}"
  ami                    = "${var.ckan_external_backup_ami}"
  vpc_security_group_ids = ["${aws_security_group.os_servers.id}"]
  ebs_optimized          = "${var.ckan_external_instance_ebs_optimized}"
  iam_instance_profile   = "${var.ckan_external_instance_profile}"
  subnet_id              = "${module.vpc.public_subnets[0]}"
  key_name               = "${aws_key_pair.cloud_key.key_name}"
  iam_instance_profile   = "${aws_iam_instance_profile.ckan.name}"

  tags {
    Name    = "${terraform.workspace} CKAN external"
    BaseAMI = "${var.ckan_external_backup_ami}"
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
    content     = "${data.template_file.ckan_upgrade.rendered}"
    destination = "/tmp/upgrade.sh"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "ubuntu"
    }
  }

  provisioner "file" {
    content = "${data.template_file.ckan_external_config.rendered}"
    destination = "/tmp/production.ini"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "ubuntu"
    }
  }

  provisioner "file" {
    content = "${data.template_file.ckan_external_nginx_config.rendered}"
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
  --s3-bucket-region ${aws_s3_bucket.ckan.region} \
  --external
EOF
    ]

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "ubuntu"
    }
  }
}

resource "aws_alb_target_group_attachment" "ckan_external_private" {
  target_group_arn = "${module.load_balancer_private.target_group_arns["${terraform.workspace}-Int-CKAN"]}"
  target_id        = "${aws_instance.ckan_external.id}"
  port             = 80
}

resource "aws_alb_target_group_attachment" "ckan_external_shared" {
  target_group_arn = "${local.shared_target_group_arns["CKAN"]}"
  target_id        = "${aws_instance.ckan_external.id}"
  port             = 80
}


resource "aws_route53_record" "ckan_external_public_dns" {
  zone_id = "${aws_route53_zone.internal_public_hosted_zone.zone_id}"
  name    = "ckan"
  type    = "A"
  count   = 1

  alias {
    name                   = "${module.load_balancer_private.dns_name}"
    zone_id                = "${module.load_balancer_private.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ckan_external_root_public_dns" {
  zone_id = "${aws_route53_zone.root_public_hosted_zone.zone_id}"
  name    = "ckan"
  type    = "A"
  count   = 1

  alias {
    name                   = "${aws_alb.shared_alb.dns_name}"
    zone_id                = "${aws_alb.shared_alb.zone_id}"
    evaluate_target_health = false
  }
}



variable "ckan_external_backup_ami" {
  description = "AMI of the ckan external image to restore"
  default = "ami-0124f020e940d4a10"
}

variable "ckan_external_instance_ebs_optimized" {
  description = "Whether or not the CKAN external server is EBS optimized"
  default     = true
}

variable "ckan_external_instance_profile" {
  description = "Instance Profile for ckan_external server"
  default     = "CloudWatch_EC2"
}

variable "ckan_external_instance_type" {
  description = "Instance type for ckan_external server"
  default     = "m4.xlarge"
}

output "ckan_external_instance_id" {
  value = "${aws_instance.ckan_external.id}"
}

output "ckan_external_private_ip" {
  value = "${aws_instance.ckan_external.private_ip}"
}