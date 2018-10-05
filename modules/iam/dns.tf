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

resource "aws_route53_record" "iam_host_record" {
  count   = "${local.iam_instance_count}"
  zone_id = "${var.zone_id}"
  name    = "${format("%s-%s", "${var.iam_hostname_prefix}", "${count.index == 0 ? "master" : "replica-${count.index}"}")}"
  type    = "A"
  ttl     = 5
  records = ["${element("${aws_instance.iam_server.*.private_ip}", "${count.index}")}"]
}

resource "aws_route53_record" "iam_host_reverse_record" {
  count   = "${local.iam_instance_count}"
  zone_id = "${aws_route53_zone.public_hosted_reverse_zone.zone_id}"
  name    = "${format("%s.%s", "${element("${split(".", "${element("${aws_instance.iam_server.*.private_ip}", "${count.index}")}")}", 3)}", "${element("${split(".", "${element("${aws_instance.iam_server.*.private_ip}", "${count.index}")}")}", 2)}")}"
  type    = "PTR"
  ttl     = 5
  records = ["${format("%s-%s.%s", "${var.iam_hostname_prefix}", "${count.index == 0 ? "master" : "replica-${count.index}"}", "${var.zone_name}")}"]
}
