locals {
  cert_env_prefix = "${terraform.workspace == "prod" ? "" : "${terraform.workspace}."}"
}

module "load_balancer_private" {
  source              = "../modules/old_prod_load_balancer"
  target_group_prefix = "${var.target_group_prefix}-Internal"
  vpc_id              = "${data.aws_vpc.default.id}"
  certificate_arn     = "${aws_acm_certificate.load_balancer.arn}"
  security_group_ids  = ["${data.aws_security_group.scos_servers.id}"]
  subnet_ids          = "${data.aws_subnet.subnet.*.id}"
  is_external         = false
}

module "load_balancer_public" {
  source              = "../modules/old_prod_load_balancer"
  target_group_prefix = "${var.target_group_prefix}"
  vpc_id              = "${data.aws_vpc.default.id}"
  certificate_arn     = "${aws_acm_certificate.load_balancer.arn}"
  security_group_ids  = ["${data.aws_security_group.scos_servers.id}", "${data.aws_security_group.scos_external_access.id}"]
  subnet_ids          = "${data.aws_subnet.subnet.*.id}"
  is_external         = true
}

resource "aws_acm_certificate" "load_balancer" {
  domain_name       = "*.${local.cert_env_prefix}smartcolumbusos.com"
  validation_method = "DNS"

  subject_alternative_names = ["${local.cert_env_prefix}smartcolumbusos.com"]
}

resource "aws_route53_record" "load_balancer_cert_validator" {
  name    = "${aws_acm_certificate.load_balancer.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.load_balancer.domain_validation_options.0.resource_record_type}"
  zone_id = "${local.public_zone_id}"
  records = ["${aws_acm_certificate.load_balancer.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "load_balancer" {
  certificate_arn         = "${aws_acm_certificate.load_balancer.arn}"
  validation_record_fqdns = ["${aws_route53_record.load_balancer_cert_validator.fqdn}"]
}

variable "target_group_prefix" {
  default     = "ProdVPC"
  description = "A prefix added to the name of the load balancers"
}
