data "template_file" "kdc_conf_tpl" {
  template = "${file("${path.module}/files/kdc/kdc.conf.tpl")}"

  vars {
    KDC_DOMAIN = "${var.kdc_domain}"
  }
}

data "template_file" "krb5_conf_tpl" {
  template = "${file("${path.module}/files/kdc/krb5.conf.tpl")}"

  vars {
    KDC_DOMAIN = "${var.kdc_domain}"
  }
}

resource "aws_route53_zone" "kdc_domain" {
  name          = "${var.kdc_domain}"
  force_destroy = true
  vpc_id = "${module.vpc.vpc_id}"

  tags = {
    Environment = "${terraform.workspace}"
  }
}

resource "aws_route53_record" "kdc_hostname_record" {
  zone_id = "${aws_route53_zone.kdc_domain.zone_id}"
  name    = "KDC-A"
  type    = "A"
  ttl     = 300
  count   = 1
  records = ["${aws_instance.kdc.private_ip}"]
}
resource "aws_instance" "kdc" {
  instance_type          = "${var.kdc_instance_type}"
  ami                    = "${var.kdc_centos_ami}"
  vpc_security_group_ids = ["${aws_security_group.os_servers.id}"]
  ebs_optimized          = "${var.kdc_instance_ebs_optimized}"
  #subnet_id              = "${module.vpc.public_subnets[0]}"
  subnet_id = "${local.hdp_subnets[0]}"
  key_name               = "${aws_key_pair.cloud_key.key_name}"

  tags {
    Name    = "${terraform.workspace} Kerberos server"
    BaseAMI = "${var.kdc_centos_ami}"
  }

  provisioner "file" {
    source     = "${path.module}/files/kdc/install-kdc.sh"
    destination = "/tmp/install-kdc.sh"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "centos"
    }
  }

  provisioner "file" {
    content = "${data.template_file.kdc_conf_tpl.rendered}"
    destination = "/tmp/kdc.conf"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "centos"
    }
  }

  provisioner "file" {
    content = "${data.template_file.krb5_conf_tpl.rendered}"
    destination = "/tmp/krb5.conf"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "centos"
    }
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
sudo bash /tmp/install-kdc.sh \
--kdc-admin-password ${random_string.kdc_admin_password.result} \
--kdc-hostname KDC-A \
--kdc-domain ${upper(var.kdc_domain)} \
--kdc-master-database-password ${random_string.kdc_master_database_password.result}
EOF
    ]

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "centos"
    }
  }
}

resource "random_string" "kdc_master_database_password" {
  length = 40
  special = false
}
resource "aws_secretsmanager_secret" "kdc_master_database_password" {
  name = "${terraform.workspace}-kdc-master-database-password"
  recovery_window_in_days = "${var.recovery_window_in_days}"
}

resource "aws_secretsmanager_secret_version" "kdc_master_database_password" {
  secret_id     = "${aws_secretsmanager_secret.kdc_master_database_password.id}"
  secret_string = "${random_string.kdc_master_database_password.result}"
}

resource "random_string" "kdc_admin_password" {
  length = 40
  special = false
}

resource "aws_secretsmanager_secret" "kdc_admin_password" {
  name = "${terraform.workspace}-kdc-admin-password"
  recovery_window_in_days = "${var.recovery_window_in_days}"

}

resource "aws_secretsmanager_secret_version" "kdc_admin_password" {
  secret_id     = "${aws_secretsmanager_secret.kdc_admin_password.id}"
  secret_string = "${random_string.kdc_admin_password.result}"
}


variable "kdc_instance_type" {
    description = "Instance size for kdc instance"
    default = "t2.medium"
}

variable "kdc_centos_ami" {
    description = "Centos AMI number"
    default = "ami-3ecc8f46"
}

variable "kdc_instance_ebs_optimized" {
    description = "Whether or not the KDC server is EBS optimized"
    default = "false"
}

variable "kdc_domain" {
    description = "Root domain for KDC"
}






