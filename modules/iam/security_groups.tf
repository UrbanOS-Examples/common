resource "aws_security_group" "iam_server_sg" {
  name   = "IAM Server SG"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow traffic from self"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.management_cidr}"]
    description = "Allow all traffic from admin VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "IAM directory traffic"
  }
}

resource "aws_security_group_rule" "iam_tcp_ingress" {
  count             = "${length(split(",", local.tcp_ports))}"
  type              = "ingress"
  from_port         = "${element(split(",", local.tcp_ports), count.index)}"
  to_port           = "${element(split(",", local.tcp_ports), count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["${var.realm_cidr}"]
  description       = "Allow inbound tcp port ${element(split(",", local.tcp_ports), count.index)}"
  security_group_id = "${aws_security_group.iam_server_sg.id}"
}

resource "aws_security_group_rule" "iam_udp_ingress" {
  count             = "${length(split(",", local.udp_ports))}"
  type              = "ingress"
  from_port         = "${element(split(",", local.udp_ports), count.index)}"
  to_port           = "${element(split(",", local.udp_ports), count.index)}"
  protocol          = "udp"
  cidr_blocks       = ["${var.realm_cidr}"]
  description       = "Allow inbound udp port ${element(split(",", local.udp_ports), count.index)}"
  security_group_id = "${aws_security_group.iam_server_sg.id}"
}
