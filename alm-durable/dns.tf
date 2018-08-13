provider "aws" {
  alias  = "prod"
  region = "${var.region}"

  assume_role {
    role_arn = "${var.prod_role_arn}"
  }
}

data "aws_route53_zone" "root_zone" {
  provider = "aws.prod"
  name = "${var.root_dns_name}"
}

resource "aws_route53_zone" "internal" {
    name = "internal.smartcolumbusos.com"
}

resource "aws_route53_record" "parent_ns_record" {
    provider = "aws.prod"
    zone_id = "${data.aws_route53_zone.root_zone.zone_id}"
    name = "${hosted_zone_name}"
    type = "NS"
    records = []
}


variable "hosted_zone_name" {
    description = "The hosted zone for the non production environments"
}

output "hosted_zone_id" {
    value = "${aws_route53_zone.internal.zone_id}"
}