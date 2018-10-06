data "template_file" "keycloak_userdata" {
  template = "${file("${path.module}/templates/keycloak-userdata.sh")}"

  vars {
    hostname         = "${var.iam_hostname_prefix}-oauth"
    hostname_prefix  = "${var.iam_hostname_prefix}"
    hosted_zone      = "${var.zone_name}"
    admin_password   = "${var.admin_password}"
    keycloak_version = "${var.keycloak_version}"
  }
}

resource "aws_instance" "keycloak_server" {
  instance_type          = "${local.iam_instance_type}"
  ami                    = "${local.iam_instance_ami}"
  vpc_security_group_ids = ["${aws_security_group.keycloak_server_sg.id}"]
  subnet_id              = "${element("${var.subnet_ids}", 1)}"
  key_name               = "${var.ssh_key}"
  user_data              = "${data.template_file.keycloak_userdata.rendered}"

  tags {
      Role     = "iam-server"
      Name     = "${var.iam_hostname_prefix}-oauth"
  }
}