
module "tls_certificate" {
  source = "github.com/azavea/terraform-aws-acm-certificate?ref=0.1.0"

  domain_name               = "${local.public_hosted_zone_name}"
  subject_alternative_names = ["*.${local.public_hosted_zone_name}"]
  hosted_zone_id            = "${aws_route53_zone.public_hosted_zone.zone_id}"
  validation_record_ttl     = "60"
}

output "tls_certificate_arn" {
  description = "ARN of the generated TLS certificate for the environment."
  value = "${module.tls_certificate.arn}"
}
