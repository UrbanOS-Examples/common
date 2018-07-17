resource "aws_route53_zone" "private" {
  name          = "${var.dns_zone_name}"
  vpc_id        = "${module.vpc.vpc_id}"
  force_destroy = true

  tags = {
    Environment = "${terraform.workspace}"
  }
}

variable "dns_zone_name" {
  description = "Name of private DNS Route53 zone"
}
