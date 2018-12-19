
module "load_balancer_private" {
  source              = "../modules/old_prod_load_balancer"
  target_group_prefix = "${terraform.workspace}-Int"
  vpc_id              = "${module.vpc.vpc_id}"
  certificate_arn     = "${module.tls_certificate.arn}"
  security_group_ids  = [
                          "${aws_security_group.os_servers.id}",
                          "${aws_security_group.allow_kubernetes_internet.id}"
                        ]
  subnet_ids          = "${local.private_subnets}"
  is_external         = false
  dns_zone            = "${terraform.workspace}.${var.root_dns_zone}"
}