/* This file contains the logical resources to create and
store parameters needed for UrbanOS deployment. The parameters
are stored in AWS System Manager Parameter Store */

resource "aws_ssm_parameter" "certificate" {
  name        = "${terraform.workspace}_certificate_arn"
  description = "Certificate ARN for Ingress"
  type        = "String"
  value       = module.tls_certificate.arn
}

resource "aws_ssm_parameter" "public_subnets" {
  name        = "${terraform.workspace}_public_subnets"
  description = "Certificate ARN for Ingress"
  type        = "String"
  value       = join("\\,", module.vpc.public_subnets)
}

resource "aws_ssm_parameter" "security_groups" {
  name        = "${terraform.workspace}_security_group_id"
  description = "AWS Security Groups ID"
  type        = "String"
  value       = aws_security_group.allow_all.id
}

resource "aws_ssm_parameter" "eks_wafv2_web_acl_arn" {
  name        = "${terraform.workspace}eks_cluster_arn"
  description = "AWS Security Groups ID"
  type        = "String"
  value       = aws_wafv2_web_acl.eks_cluster.arn
}