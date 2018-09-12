resource "aws_route53_record" "joomla_dns_record" {
  count   = "${var.dns_entries_enabled}"
  zone_id = "${var.hosted_zone_id}"
  name    = ""
  type    = "A"
  count   = 1

  alias {
    name                   = "${module.load_balancer_public.dns_name}"
    zone_id                = "${module.load_balancer_public.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "joomla_www_dns_record" {
  count   = "${var.dns_entries_enabled}"
  zone_id = "${var.hosted_zone_id}"
  name    = "www"
  type    = "A"
  count   = 1

  alias {
    name                   = "${module.load_balancer_public.dns_name}"
    zone_id                = "${module.load_balancer_public.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ckan_external_dns_record" {
  count   = "${var.dns_entries_enabled}"
  zone_id = "${var.hosted_zone_id}"
  name    = "ckan"
  type    = "A"
  count   = 1

  alias {
    name                   = "${module.load_balancer_public.dns_name}"
    zone_id                = "${module.load_balancer_public.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "kong_dns_record" {
  count   = "${var.dns_entries_enabled}"
  zone_id = "${var.hosted_zone_id}"
  name    = "api"
  type    = "A"
  count   = 1

  alias {
    name                   = "${module.load_balancer_public.dns_name}"
    zone_id                = "${module.load_balancer_public.zone_id}"
    evaluate_target_health = false
  }
}

variable "dns_entries_enabled" {
  default = 0
}
