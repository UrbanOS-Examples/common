resource "aws_security_group" "os_servers" {
  name   = "OS Servers"
  vpc_id = "${module.vpc.vpc_id}"

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
    cidr_blocks = ["${data.terraform_remote_state.alm_remote_state.vpc_cidr_block}"]
    description = "Allow all traffic from admin VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "load_balancer_private" {
  source              = "../modules/old_prod_load_balancer"
  target_group_prefix = "${terraform.workspace}-Int"
  vpc_id              = "${module.vpc.vpc_id}"
  certificate_arn     = "${module.tls_certificate.arn}"
  security_group_ids  = ["${aws_security_group.os_servers.id}"]
  subnet_ids          = "${module.vpc.private_subnets}"
  is_external         = false
  dns_zone            = "${terraform.workspace}.${var.root_dns_zone}"
}

output "os_servers_sg_id" {
  value = "${aws_security_group.os_servers.id}"
}