locals {
  internal_public_hosted_zone_name = "${lower(terraform.workspace)}.${lower(var.internal_root_dns_zone)}"
}

resource "aws_route53_zone" "internal_public_hosted_zone" {
  name          = "${local.internal_public_hosted_zone_name}"
  force_destroy = true

  tags = {
    Environment = "${terraform.workspace}"
  }
}

resource "aws_route53_record" "alm_ns_record" {
  provider = "aws.alm"

  name    = "${terraform.workspace}"
  zone_id = "${data.terraform_remote_state.durable.hosted_zone_id}"
  type    = "NS"
  ttl     = 300
  records = ["${aws_route53_zone.internal_public_hosted_zone.name_servers}"]
}

variable "internal_root_dns_zone" {
  description = "Name of root domain (ex. example.com)"
  default     = "internal.smartcolumbusos.com"
}

variable "prod_dns_zone" {
  description = "Set this when deploying to prod environments to override the default internal.smartcolumbusos.com zones for application configs"
  default     = ""
}

output "dns_zone_name" {
  value       = "${coalesce("${var.prod_dns_zone}","${local.internal_public_hosted_zone_name}")}"
  description = "DEPRECATED - DO NOT USE"
}

output "internal_dns_zone_name" {
  value = "${local.internal_public_hosted_zone_name}"
}
