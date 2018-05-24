resource "aws_instance" "openvpn_instance" {
  ami                    = "ami-6d163708"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  subnet_id              = "${var.public_subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.openvpn.id}"]

  lifecycle = {
    # The OpenVPN Access Server license can only be activated once.  If the instance is destroyed, a new
    # license key needs to be obtained by contacting OpenVPN support.
    # https://docs.openvpn.net/getting-started/amazon-web-services-ec2-byol-appliance-quick-start-guide/
    prevent_destroy = "true"
  }

  user_data = <<USERDATA
#!/bin/bash

cat <<EOF >> /etc/network/interfaces
auto eth1
iface eth1 inet dhcp
EOF

ifup eth1

# Swap ports so that web traffic listens on 443 to eliminate port needed in URL
sed -i 's/"cs\.https\.port"\: "943",/"cs\.https\.port"\: "443",/' /usr/local/openvpn_as/etc/config.json
sed -i 's/"vpn\.server\.daemon\.tcp\.port"\: "443",/"vpn\.server\.daemon\.tcp\.port"\: "943",/' /usr/local/openvpn_as/etc/config.json

# OpenVPN reads the userdata for key value pairs for automatic self configuration
# These are the known (undocumented) variables that the OpenVPN AS consumes
admin_user=${var.admin_user}
admin_pw=${var.admin_password}
# License key cannot be reused, so it should not be set automatically
license=
local_auth=${var.local_auth}
reroute_dns=${var.reroute_dns}
reroute_gw=${var.reroute_gw}
public_hostname=${aws_eip.openvpn_eip.public_ip}
USERDATA

  tags {
    Name = "OpenVPN"
  }

  depends_on = ["aws_eip.openvpn_eip", "aws_security_group.openvpn"]
}

resource "aws_eip" "openvpn_eip" {
  vpc = true
}

resource "aws_eip_association" "openvpn_eip_association" {
  instance_id   = "${aws_instance.openvpn_instance.id}"
  allocation_id = "${aws_eip.openvpn_eip.id}"
  depends_on    = ["aws_instance.openvpn_instance", "aws_eip.openvpn_eip"]
}

resource "aws_network_interface" "private_vpn_nic" {
  subnet_id = "${var.private_subnet_id}"

  attachment {
    instance     = "${aws_instance.openvpn_instance.id}"
    device_index = 1
  }
}

resource "aws_security_group" "openvpn" {
  name        = "openvpn"
  description = "Allow the internet to get to the OpenVPN ports"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 943
    to_port     = 943
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "udp"
    from_port   = 1194
    to_port     = 1194
    cidr_blocks = ["0.0.0.0/0"]
  }
}
