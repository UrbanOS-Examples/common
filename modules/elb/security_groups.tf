data "aws_vpc" "network" {
  id = "${var.vpc_id}"
}

resource "aws_security_group" "load_balancer" {
  name = "elb-${var.component}-${var.deployment_identifier}"
  vpc_id = "${var.vpc_id}"
  description = "ELB for component: ${var.component}, service: ${var.service_name}, deployment: ${var.deployment_identifier}"

  # had to change this from 443. This is coupled with ELB listeners
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.allow_cidrs}"]
  }

  egress {
    from_port = 1
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      "${coalescelist(var.egress_cidrs, list(data.aws_vpc.network.cidr_block))}"
    ]
  }
}

resource "aws_security_group" "open_to_load_balancer" {
  name = "open-to-elb-${var.component}-${var.deployment_identifier}"
  vpc_id = "${var.vpc_id}"
  description = "Open to ELB for component: ${var.component}, service: ${var.service_name}, deployment: ${var.deployment_identifier}"

  ingress {
    from_port = "${var.service_port}"
    to_port = "${var.service_port}"
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.load_balancer.id}"
    ]
  }
}
