locals {
  is_prod   = "${terraform.workspace == "prod" ? 1 : 0}"
  zone_name = "${local.is_prod ? var.root_dns_name : format("%s.%s", terraform.workspace, var.root_dns_name)}"
}

resource "aws_route53_zone" "public_hosted_zone" {
  name          = "${local.zone_name}"
  force_destroy = true

  tags = {
    Environment = "${terraform.workspace}"
  }
}
module "alm_dns" {
  source                = "../modules/remote_dns/"
  remote_workspace      = "alm"
  remote_bucket_name    = "${var.alm_state_bucket_name}"
  remote_region         = "${var.alm_region}"
  remote_role_arn       = "${var.alm_role_arn}"
  public_hosted_zone_id = "${aws_route53_zone.public_hosted_zone.zone_id}"
  count                 = "${local.is_prod}"
  key                   = "alm"
}

variable "root_dns_name" {
  description = "Name of root domain (ex. example.com)"
}

output "name_servers" {
  value = "${aws_route53_zone.public_hosted_zone.name_servers}"
}

output "domain_zone_id" {
  value = "${aws_route53_zone.public_hosted_zone.zone_id}"
}
