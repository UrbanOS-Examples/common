resource "random_shuffle" "private_subnet" {
  input = ["${var.subnets}"]

  keepers = {
    private_subnets = "${join(",", var.subnets)}"
  }
}

resource "random_string" "cloudbreak_cluster_secret" {
  length  = 40
  special = false
}

resource "aws_secretsmanager_secret" "cloudbreak_cluster_secret" {
  name = "${terraform.workspace}-cloudbreak-cluster-secret"
}

resource "aws_secretsmanager_secret_version" "cloudbreak_cluster_secret" {
  secret_id     = "${aws_secretsmanager_secret.cloudbreak_cluster_secret.id}"
  secret_string = "${random_string.cloudbreak_cluster_secret.result}"
}

resource "random_string" "cloudbreak_admin_password" {
  length  = 40
  special = false
}

resource "aws_secretsmanager_secret" "cloudbreak_admin_password" {
  name = "${terraform.workspace}-cloudbreak-admin-password"
}

resource "aws_secretsmanager_secret_version" "cloudbreak_admin_password" {
  secret_id     = "${aws_secretsmanager_secret.cloudbreak_admin_password.id}"
  secret_string = "${random_string.cloudbreak_admin_password.result}"
}

data "template_file" "cloudbreak_profile" {
  template = "${file("${path.module}/templates/Profile.tpl")}"

  vars {
    UAA_DEFAULT_SECRET     = "${random_string.cloudbreak_cluster_secret.result}"
    UAA_DEFAULT_USER_PW    = "${random_string.cloudbreak_admin_password.result}"
    UAA_DEFAULT_USER_EMAIL = "admin@smartcolumbusos.com"
    PUBLIC_IP              = "cloudbreak.${var.cloudbreak_dns_zone_name}"

    DATABASE_HOST     = "${aws_db_instance.cloudbreak_db.address}"
    DATABASE_PORT     = "${aws_db_instance.cloudbreak_db.port}"
    DATABASE_USERNAME = "${aws_db_instance.cloudbreak_db.username}"
    DATABASE_PASSWORD = "${random_string.cloudbreak_db_password.result}"
  }
}

data "aws_ami" "cloudbreak" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-aws-cloudbreak-${var.cloudbreak_version}-*"]
  }

  owners = [
    "068920858268",
    "199837183662",
  ]
}

resource "aws_instance" "cloudbreak" {
  instance_type          = "t2.xlarge"
  ami                    = "${data.aws_ami.cloudbreak.id}"
  vpc_security_group_ids = ["${aws_security_group.cloudbreak_security_group.id}"]
  ebs_optimized          = "false"
  subnet_id              = "${local.cluster_subnet}"
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
    setup_updated    = "${sha1(file(local.start_cloudbreak_path))}"
    config_updated   = "${sha1(data.template_file.cloudbreak_profile.rendered)}"
  }

  connection {
    type = "ssh"
    host = "${aws_instance.cloudbreak.private_ip}"
    user = "ec2-user"
  }

  provisioner "file" {
    //newline included here because Cloudbreak appends to the end of this file
    content     = "${data.template_file.cloudbreak_profile.rendered}\n"
    destination = "/tmp/Profile"
  }

  provisioner "file" {
    source      = "${local.start_cloudbreak_path}"
    destination = "/tmp/start_cloudbreak.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/start_cloudbreak.sh /tmp/Profile",
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "cloudbreak_credential" {
  triggers {
    instance_updated = "${null_resource.cloudbreak.id}"
    setup_updated    = "${sha1(file(local.ensure_credentials_path))}"
    id_updated       = "${local.cb_credential_name}"
  }

  depends_on = [
    "aws_iam_role_policy.cloudbreak_credential",
  ]

  connection {
    type = "ssh"
    host = "${aws_instance.cloudbreak.private_ip}"
    user = "ec2-user"
  }

  provisioner "file" {
    source      = "${local.ensure_credentials_path}"
    destination = "/tmp/ensure_credentials.sh"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
bash /tmp/ensure_credentials.sh \
  ${local.cb_credential_name} \
  ${aws_iam_role.cloudbreak_credential.arn}
EOF
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}
