module "tls_certificate" {
  source = "github.com/azavea/terraform-aws-acm-certificate?ref=3.0.0"

  providers = {
    aws.acm_account     = aws
    aws.route53_account = aws
  }

  domain_name = coalesce(
    var.tls_certificate_dns_name_override,
    local.internal_public_hosted_zone_name,
  )
  subject_alternative_names = ["*.${coalesce(
    var.tls_certificate_dns_name_override,
    local.internal_public_hosted_zone_name,
  )}"]
  hosted_zone_id = coalesce(
    var.tls_certificate_public_hosted_zone_id_override,
    aws_route53_zone.internal_public_hosted_zone.zone_id,
  )
  validation_record_ttl = "60"
}

locals {
  root_tls_cert_domain_name = var.is_sandbox ? local.internal_public_hosted_zone_name : var.root_dns_zone

  root_tls_cert_subject_alternative_names = var.is_sandbox ? local.internal_public_hosted_zone_name : var.root_dns_zone
  root_tls_cert_hosted_zone_id            = var.is_sandbox ? aws_route53_zone.internal_public_hosted_zone.zone_id : aws_route53_zone.root_public_hosted_zone.zone_id
}

module "root_tls_certificate" {
  source = "github.com/azavea/terraform-aws-acm-certificate?ref=3.0.0"

  providers = {
    aws.acm_account     = aws
    aws.route53_account = aws
  }

  domain_name               = local.root_tls_cert_domain_name
  subject_alternative_names = ["*.${local.root_tls_cert_subject_alternative_names}"]
  hosted_zone_id            = local.root_tls_cert_hosted_zone_id
  validation_record_ttl     = "60"
}

variable "tls_certificate_dns_name_override" {
  description = "If we should be using a different DNS hostname (such as 'smartcolumbusos.com') for our TLS certificates instead of the autogenerated one, please specify it here. Otherwise, leave this blank."
  default     = ""
}

variable "tls_certificate_public_hosted_zone_id_override" {
  description = "If we should be using a different public hosted zone for inserting ACM certificate validation records instead of the autogenerated one, please specify it here."
  default     = ""
}

output "tls_certificate_arn" {
  description = "ARN of the generated TLS certificate for the environment."
  value       = module.tls_certificate.arn
}

output "root_tls_certificate_arn" {
  description = "ARN of the generated root TLS certificate for the environment"
  value       = module.root_tls_certificate.arn
}

