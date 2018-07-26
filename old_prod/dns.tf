locals {
  zone_name = "${format("%s.%s", terraform.workspace, "scos-internal.com")}"
}

resource "aws_route53_zone" "private_hosted_zone" {
  name          = "${local.zone_name}"
  force_destroy = true
  vpc_id        = "${data.aws_vpc.default.id}"

  tags = {
    Environment = "${terraform.workspace}"
  }
}
