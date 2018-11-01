resource "aws_instance" "freeipa_master" {
  instance_type          = "${local.iam_instance_type}"
  ami                    = "${local.iam_instance_ami}"
  vpc_security_group_ids = ["${aws_security_group.freeipa_server_sg.id}"]
  subnet_id              = "${element("${var.subnet_ids}", "0")}"
  key_name               = "${var.ssh_key}"

  tags {
      Role     = "iam-server"
      Name     = "${var.iam_hostname_prefix}-master"
  }

  provisioner "file" {
    source      = "${path.module}/files/freeipa/setup_master.sh"
    destination = "/tmp/setup_master.sh"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "fedora"
    }
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
sudo bash /tmp/setup_master.sh \
  --hostname ${var.iam_hostname_prefix}-master \
  --hosted-zone ${var.zone_name} \
  --admin-password ${var.admin_password}
EOF
    ]

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "fedora"
    }
  }
}

resource "aws_instance" "freeipa_replica" {
  count                  = "${local.freeipa_replica_count}"
  instance_type          = "${local.iam_instance_type}"
  ami                    = "${local.iam_instance_ami}"
  vpc_security_group_ids = ["${aws_security_group.freeipa_server_sg.id}"]
  subnet_id              = "${element("${var.subnet_ids}", "${(count.index + 1) % 3}")}"
  key_name               = "${var.ssh_key}"

  tags {
      Role     = "iam-server"
      Name     = "${var.iam_hostname_prefix}-replica-${count.index}"
  }

  provisioner "file" {
    source      = "${path.module}/files/freeipa/setup_replica.sh"
    destination = "/tmp/setup_replica.sh"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "fedora"
    }
  }

  provisioner "file" {
    source      = "${path.module}/files/freeipa/finalize_replica.sh"
    destination = "/tmp/finalize_replica.sh"

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "fedora"
    }
  }

  provisioner "file" {
    source      = "${path.module}/files/freeipa/register_replica.sh"
    destination = "/tmp/register_replica.sh"

    connection {
      type = "ssh"
      host = "${aws_instance.freeipa_master.private_ip}"
      user = "fedora"
    }
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
sudo bash /tmp/setup_replica.sh \
  --hostname ${var.iam_hostname_prefix}-replica-${count.index} \
  --hostname-prefix ${var.iam_hostname_prefix} \
  --hosted-zone ${var.zone_name} \
  --admin-password ${var.admin_password}
EOF
    ]

    connection {
      type = "ssh"
      host = "${self.private_ip}"
      user = "fedora"
    }
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
sudo bash /tmp/register_replica.sh \
  --hostname ${var.iam_hostname_prefix}-replica-${count.index} \
  --hosted-zone ${var.zone_name} \
  --admin-password ${var.admin_password}
EOF
    ]

    connection {
      type = "ssh"
      host = "${aws_instance.freeipa_master.private_ip}"
      user = "fedora"
    }
  }
}

# FreeIPA replicas can only be registered with forward and reverse DNS records already created
resource "null_resource" "freeipa_replica_finalizer" {
  count = "${local.freeipa_replica_count}"
  depends_on = [
    "aws_route53_record.freeipa_replica_host_record",
    "aws_route53_record.freeipa_replica_host_reverse_record"
  ]

  provisioner "remote-exec" {
    inline = [
      <<EOF
sudo bash /tmp/finalize_replica.sh \
  --admin-password ${var.admin_password}
EOF
    ]

    connection {
      type = "ssh"
      host = "${element("${aws_instance.freeipa_replica.*.private_ip}", count.index)}"
      user = "fedora"
    }
  }
}
