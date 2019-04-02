# #Assumption: We've changed internal_root_dns_zone to be ONLY the root URL
locals {
  root_public_hosted_zone_name = "${lower(var.root_dns_zone)}"
}

resource "aws_route53_zone" "root_public_hosted_zone" {
  name          = "${local.root_public_hosted_zone_name}"
  force_destroy = true
}

variable "root_dns_zone" {
    description = "root dns zone name"
    default = "smartcolumbusos.com"
}

resource "aws_route53_record" "cota_root_record" {
  zone_id = "${aws_route53_zone.root_public_hosted_zone.zone_id}"
  name    = "cota"
  type    = "CNAME"
  ttl     = 300
  records = ["cota.${aws_route53_zone.internal_public_hosted_zone.name}"]
  lifecycle = { ignore_changes = ["allow_overwrite"] }
}

resource "aws_route53_record" "jupyter_root_record" {
  zone_id = "${aws_route53_zone.root_public_hosted_zone.zone_id}"
  name    = "jupyter"
  type    = "CNAME"
  ttl     = 300
  records = ["jupyter.${aws_route53_zone.internal_public_hosted_zone.name}"]
  lifecycle = { ignore_changes = ["allow_overwrite"] }
}

resource "aws_route53_record" "streaming_root_record" {
  zone_id = "${aws_route53_zone.root_public_hosted_zone.zone_id}"
  name    = "streaming"
  type    = "CNAME"
  ttl     = 300
  records = ["socket.${aws_route53_zone.internal_public_hosted_zone.name}"]
  lifecycle = { ignore_changes = ["allow_overwrite"] }
}

output "root_dns_zone_name" {
  value = "${local.root_public_hosted_zone_name}"
}
