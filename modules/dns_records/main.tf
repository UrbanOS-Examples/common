variable "name" {
  description = "Name of the route53 record"
}

variable "dns_name" {
  description = "Load Balancer dns name"
}

variable "lb_zone_id" {
  description = "Zone id from the load balancer"
}

variable "public_zone_id" {}

variable "compatability_zone_id" {}

variable "alm_zone_id" {
  description = "Private zone id for the ALM network"
}

locals {
  is_prod        = "${terraform.workspace == "prod" ? 1 : 0}"
  env_dns_prefix = "${local.is_prod ? "" : format(".%s", terraform.workspace)}"
}

/*
To add a DNS record requires two records - one for private DNS and one for public
public zone is ${aws_route53_zone.public_hosted_zone.zone_id}
private zone is ${data.terraform_remote_state.alm_remote_state.private_zone_id}
*/

resource "aws_route53_record" "public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.name}"
  type    = "A"
  count   = 1

  alias {
    name                   = "${var.dns_name}"
    zone_id                = "${var.lb_zone_id}"
    evaluate_target_health = false
  }
}

/*
This DNS record is here for compatibility with the manually managed zones
until we can migrate them over
*/
resource "aws_route53_record" "compatibility" {
  zone_id = "${var.compatability_zone_id}"
  name    = "${var.name}"
  type    = "A"
  count   = 1

  alias {
    name                   = "${var.dns_name}"
    zone_id                = "${var.lb_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "alm" {
  provider = "aws.alm"
  zone_id  = "${var.alm_zone_id}"
  name     = "${var.name}${local.env_dns_prefix}"
  type     = "A"
  count    = 1

  alias {
    name                   = "${var.dns_name}"
    zone_id                = "${var.lb_zone_id}"
    evaluate_target_health = false
  }
}
