locals {
  public_hosted_zone_name = "${lower(terraform.workspace)}.${lower(var.root_dns_zone)}"
}

data "terraform_remote_state" "durable" {
  backend   = "s3"
  workspace = "${var.alm_workspace}"

  config {
    bucket   = "${var.alm_state_bucket_name}"
    key      = "alm-durable"
    region   = "us-east-2"
    role_arn = "${var.alm_role_arn}"
  }
}

resource "aws_route53_zone" "public_hosted_zone" {
  name          = "${local.public_hosted_zone_name}"
  force_destroy = true

  tags = {
    Environment = "${terraform.workspace}"
  }
}

resource "aws_route53_record" "alm_ns_record" {
  provider = "aws.alm"

  name = "${terraform.workspace}"
  zone_id = "${data.terraform_remote_state.durable.hosted_zone_id}"
  type = "NS"
  ttl = 300
  records = ["${aws_route53_zone.public_hosted_zone.name_servers}"]
}

variable "root_dns_zone" {
  description = "Name of root domain (ex. example.com)"
  default     = "internal.smartcolumbusos.com"
}

variable "prod_dns_zone" {
  description = "Set this when deploying to prod environments to override the default internal.smartcolumbusos.com zones for application configs"
  default     = ""
}

output "dns_zone_name" {
  value = "${coalesce("${var.prod_dns_zone}","${aws_route53_zone.public_hosted_zone.name}")}"
}