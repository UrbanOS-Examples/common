resource "aws_route53_zone" "public_hosted_zone" {
  name          = "${terraform.workspace}.${var.root_dns_zone}"
  force_destroy = true

  tags = {
    Environment = "${terraform.workspace}"
  }
}

resource "aws_route53_record" "alm_ns_record" {
  name = "${terraform.workspace}"
  zone_id = "${data.terraform_remote_state.alm_state.public_hosted_zone_id}"
  type = "NS"
  ttl = 300
  records = ["${aws_route53_zone.public_hosted_zone.name_servers}"]
}

variable "root_dns_zone" {
  description = "Name of root domain (ex. example.com)"
}
