module "load_balancer_private" {
  source              = "../modules/old_prod_load_balancer"
  target_group_prefix = "${terraform.workspace}-Int"
  vpc_id              = "${module.vpc.vpc_id}"
  certificate_arn     = "${module.tls_certificate.arn}"
  security_group_ids  = ["${aws_security_group.os_servers.id}"]
  subnet_ids          = "${module.vpc.private_subnets}"
  is_external         = false
  root_dns_zone = "${var.root_dns_zone}"
  }

module "load_balancer_public" {
  source              = "../modules/old_prod_load_balancer"
  target_group_prefix = "${terraform.workspace}"
  vpc_id              = "${module.vpc.vpc_id}"
  certificate_arn     = "${module.tls_certificate.arn}"
  security_group_ids  = ["${aws_security_group.os_servers.id}", "${aws_security_group.os_external_access.id}"]
  subnet_ids          = "${module.vpc.public_subnets}"
  is_external         = true
  root_dns_zone = "${var.root_dns_zone}" 
}