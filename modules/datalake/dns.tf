resource "aws_route53_zone" "hadoop" {
  name   =  "${local.cluster_name}.${var.domain_name}"
  vpc_id = "${var.vpc_id}"
}
