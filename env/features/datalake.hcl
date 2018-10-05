module "datalake" {
  source = "../modules/datalake"

  vpc_id                 = "${module.vpc.vpc_id}"
  subnets                = "${module.vpc.private_subnets}"
  remote_management_cidr = "${data.terraform_remote_state.alm_remote_state.vpc_cidr_block}"
  alb_certificate        = "${module.tls_certificate.arn}"
  cloudbreak_dns_zone    = "${aws_route53_zone.public_hosted_zone.zone_id}"
  cloudbreak_tag         = "1.0.0"
}
