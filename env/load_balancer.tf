locals {
  cert_env_prefix = "${terraform.workspace == "prod" ? "" : "${terraform.workspace}.${var.root_dns_zone}"}"
}

module "load_balancer_private" {
  source              = "../modules/old_prod_load_balancer"
  target_group_prefix = "${terraform.workspace}-Int"
  vpc_id              = "${module.vpc.vpc_id}"
  certificate_arn     = "${aws_acm_certificate.load_balancer.arn}"
  security_group_ids  = ["${aws_security_group.os_servers.id}"]
  subnet_ids          = "${module.vpc.private_subnets}"
  is_external         = false
  root_dns_zone = "${var.root_dns_zone}"
  }

module "load_balancer_public" {
  source              = "../modules/old_prod_load_balancer"
  target_group_prefix = "${terraform.workspace}"
  vpc_id              = "${module.vpc.vpc_id}"
  certificate_arn     = "${aws_acm_certificate.load_balancer.arn}"
  security_group_ids  = ["${aws_security_group.os_servers.id}", "${aws_security_group.os_external_access.id}"]
  subnet_ids          = "${module.vpc.public_subnets}"
  is_external         = true
  root_dns_zone = "${var.root_dns_zone}" 
}

resource "aws_acm_certificate" "load_balancer" {
  domain_name       = "*.${local.cert_env_prefix}"
  validation_method = "DNS"

  subject_alternative_names = ["${local.cert_env_prefix}"]
}

resource "aws_route53_record" "load_balancer_cert_validator" {
  name    = "${aws_acm_certificate.load_balancer.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.load_balancer.domain_validation_options.0.resource_record_type}"
  zone_id = "${aws_route53_zone.public_hosted_zone.zone_id}"
  records = ["${aws_acm_certificate.load_balancer.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "load_balancer" {
  certificate_arn         = "${aws_acm_certificate.load_balancer.arn}"
  validation_record_fqdns = ["${aws_route53_record.load_balancer_cert_validator.fqdn}"]

  depends_on = ["aws_route53_record.alm_ns_record"]
  timeouts {
    create = "30m"
  }
}
