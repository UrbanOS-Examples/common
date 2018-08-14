provider "aws" {
  alias  = "prod"
  region = "us-east-1"

  assume_role {
    role_arn = "${var.root_zone_role_arn}"
  }
}

data "aws_route53_zone" "root_zone" {
  provider = "aws.prod"
  name = "${var.root_zone_name}"
}

resource "aws_route53_zone" "internal" {
    name = "${var.hosted_zone_name}.${var.root_zone_name}"
}

resource "aws_route53_record" "parent_ns_record" {
    provider        = "aws.prod"
    zone_id         = "${data.aws_route53_zone.root_zone.zone_id}"
    name            = "${var.hosted_zone_name}"
    ttl             = 300
    type            = "NS"
    records         = ["${aws_route53_zone.internal.name_servers}"]

    lifecycle {
        ignore_changes = ["name", "allow_overwrite"]
    }
}

variable "root_zone_name" {}

variable "root_zone_role_arn" {
    description = "Role arn that allows manipulating of the root zone"
}

variable "hosted_zone_name" {
    description = "The hosted zone for the non production environments"
}

output "hosted_zone_id" {
    value = "${aws_route53_zone.internal.zone_id}"
}