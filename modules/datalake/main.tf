data "aws_caller_identity" "current" {}

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
  template = "${file("${path.module}/templates/Profile.tpl")}"

  vars {
    UAA_DEFAULT_SECRET="${random_string.cloudbreak_cluster_secret.result}"
    UAA_DEFAULT_USER_PW="${random_string.cloudbreak_admin_password.result}"
    UAA_DEFAULT_USER_EMAIL="admin@smartcolumbusos.com"
    PUBLIC_IP="cloudbreak.${var.cloudbreak_dns_zone}"

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
      value = "${var.cloudbreak_version}"
    }
  ]

  owners = [
    "068920858268",
    "199837183662"
  ]
}

resource "random_shuffle" "private_subnet" {
  input   = ["${var.subnets}"]
  keepers = {
    private_subnets = "${join(",", var.subnets)}"
  }
}

resource "aws_instance" "cloudbreak" {
  instance_type          = "t2.xlarge"
  ami                    = "${data.aws_ami.cloudbreak.id}"
  vpc_security_group_ids = ["${aws_security_group.cloudbreak_security_group.id}"]
  ebs_optimized          = "false"
  subnet_id              = "${random_shuffle.private_subnet.result[0]}"
  key_name               = "${var.ssh_key}"
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
    setup_updated    = "${sha1(file("${path.module}/templates/setup.sh"))}"
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
    source = "${path.module}/templates/setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x /tmp/setup.sh && sudo /tmp/setup.sh"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

