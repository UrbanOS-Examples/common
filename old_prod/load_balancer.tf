locals {
  url_subdomain_by_env = "${terraform.workspace == "prod" ? "" : terraform.workspace}"
  cert_env_prefix      = "${local.url_subdomain_by_env == "" ? "" : "${local.url_subdomain_by_env}."}"
}

module "load_balancer" {
  source              = "../modules/old_prod_load_balancer"
  target_group_prefix = "${var.target_group_prefix}-Internal"
  vpc_id              = "${data.aws_vpc.default.id}"
  certificate_arn     = "${aws_acm_certificate.load_balancer.arn}"
  security_group_id   = "${data.aws_security_group.scos_servers.id}"
  subnet_ids          = "${data.aws_subnet.subnet.*.id}"
  is_external         = false
  is_enabled          = true
  env_subdomain       = "${local.url_subdomain_by_env}"
}

module "load_balancer_external" {
  source              = "../modules/old_prod_load_balancer"
  target_group_prefix = "${var.target_group_prefix}"
  vpc_id              = "${data.aws_vpc.default.id}"
  certificate_arn     = "${aws_acm_certificate.load_balancer.arn}"
  security_group_id   = "${data.aws_security_group.scos_servers.id}"
  subnet_ids          = "${data.aws_subnet.subnet.*.id}"
  is_external         = true
  is_enabled          = "${var.alb_external}"
  env_subdomain       = "${local.url_subdomain_by_env}"
}

resource "aws_acm_certificate" "load_balancer" {
  domain_name       = "*.${local.cert_env_prefix}smartcolumbusos.com"
  validation_method = "DNS"

  subject_alternative_names = ["${local.cert_env_prefix}smartcolumbusos.com"]
}

variable "target_group_prefix" {
  default = "PROD"
}

variable "alb_external" {
  description = "Create an external load balancer?"
  default     = true
}
