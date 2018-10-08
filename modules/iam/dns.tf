locals {
  reverse_cidr = "${format("%s.%s", "${element("${split(".", "${var.vpc_cidr}")}", 1)}", "${element("${split(".", "${var.vpc_cidr}")}", 0)}")}"
}

resource "aws_route53_zone" "public_hosted_reverse_zone" {
  name              = "${local.reverse_cidr}.in-addr.arpa"
  vpc_id            = "${var.vpc_id}"
  force_destroy     = true

  tags = {
    Environment = "${terraform.workspace}"
  }
}

resource "aws_route53_record" "freeipa_host_record" {
  count   = "${local.freeipa_instance_count}"
  zone_id = "${var.zone_id}"
  name    = "${format("%s-%s", "${var.iam_hostname_prefix}", "${count.index == 0 ? "master" : "replica-${count.index}"}")}"
  type    = "A"
  ttl     = 5
  records = ["${element("${aws_instance.freeipa_server.*.private_ip}", "${count.index}")}"]
}

resource "aws_route53_record" "keycloak_lb_record" {
  zone_id = "${var.zone_id}"
  name    = "${var.iam_hostname_prefix}-oauth"
  type    = "A"
  ttl     = 5
  records = ["${aws_instance.keycloak_server.private_ip}"]
}

resource "aws_route53_record" "keycloak_lb_record" {
  zone_id = "${var.zone_id}"
  name    = "oauth"
  type    = "A"

  alias {
    name                   = "${aws_alb.keycloak.dns_name}"
    zone_id                = "${aws_alb.keycloak.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "freeipa_host_reverse_record" {
  count   = "${local.freeipa_instance_count}"
  zone_id = "${aws_route53_zone.public_hosted_reverse_zone.zone_id}"
  name    = "${format("%s.%s", "${element("${split(".", "${element("${aws_instance.freeipa_server.*.private_ip}", "${count.index}")}")}", 3)}", "${element("${split(".", "${element("${aws_instance.freeipa_server.*.private_ip}", "${count.index}")}")}", 2)}")}"
  type    = "PTR"
  ttl     = 5
  records = ["${format("%s-%s.%s", "${var.iam_hostname_prefix}", "${count.index == 0 ? "master" : "replica-${count.index}"}", "${var.zone_name}")}"]
}
