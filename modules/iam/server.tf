data "template_file" "iam_user_data" {
  count    = "${local.iam_instance_count}"
  template = "${file("${path.module}/templates/user-data-iam.sh")}"

  vars {
    hostname        = "${format("%s-%s", "${var.iam_hostname_prefix}", "${count.index == 0 ? "master" : "replica-${count.index}"}")}"
    hostname_prefix = "${var.iam_hostname_prefix}"
    hosted_zone     = "${var.zone_name}"
    admin_password  = "${var.admin_password}"
  }
}

resource "aws_instance" "iam_server" {
  count                  = "${local.iam_instance_count}"
  instance_type          = "${local.iam_instance_type}"
  ami                    = "${local.iam_instance_ami}"
  vpc_security_group_ids = ["${aws_security_group.iam_server_sg.id}"]
  subnet_id              = "${element("${var.subnet_ids}", "${count.index%3}")}"
  key_name               = "${var.ssh_key}"
  user_data              = "${element("${data.template_file.iam_user_data.*.rendered}", "${count.index}")}"

  tags {
      Role     = "iam-server"
      Name     = "${format("%s-%s", "${var.iam_hostname_prefix}", "${count.index == 0 ? "master" : "replica-${count.index}"}")}"
  }
}
