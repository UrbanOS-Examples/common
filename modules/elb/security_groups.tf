data "aws_vpc" "network" {
  id = "${var.vpc_id}"
}

resource "aws_security_group" "load_balancer" {
  name = "elb-${var.component}-${var.deployment_identifier}"
  vpc_id = "${var.vpc_id}"
  description = "ELB for component: ${var.component}, service: ${var.service_name}, deployment: ${var.deployment_identifier}"

  # had to change this from 443. This is coupled with ELB listeners
  ingress = ["${var.ingress_rules}"]

  egress {
    from_port = 1
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      "${coalescelist(var.egress_cidrs, list(data.aws_vpc.network.cidr_block))}"
    ]
  }
}
