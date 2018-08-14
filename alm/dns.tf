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

resource "aws_route53_zone" "public_hosted_zone" {
  name          = "${var.environment}.${var.root_dns_name}"
  force_destroy = true

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_route53_record" "alm_ns_record" {
  provider = "aws.prod"
  name = "${var.environment}"
  zone_id = "${data.aws_route53_zone.root_zone.zone_id}"
  type = "NS"
  ttl = 300
  records = ["${aws_route53_zone.public_hosted_zone.name_servers}"]
}

variable "root_dns_name" {
  description = "Name of root domain (ex. example.com)"
}

variable "prod_role_arn" {
  description = "Role that allows for route53 record manipulation in prod"
}

output "name_servers" {
  value = "${aws_route53_zone.public_hosted_zone.name_servers}"
}
