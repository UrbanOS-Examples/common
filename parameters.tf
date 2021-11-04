/* This file contains the logical resources to create and
store parameters needed for UrbanOS deployment. The parameters
are stored in AWS System Manager Parameter Store */

resource "aws_ssm_parameter" "certificate" {
  name        = "${terraform.workspace}_certificate_arn"
  description = "Certificate ARN for Ingress"
  type        = "String"
  value       = module.tls_certificate.arn
}

resource "aws_ssm_parameter" "root_certificate" {
  name        = "${terraform.workspace}_certificate_arn"
  description = "Certificate ARN for Ingress"
  type        = "String"
  value       = module.root_tls_certificate.arn
}

resource "aws_ssm_parameter" "public_subnets" {
  name        = "${terraform.workspace}_public_subnets"
  description = "Public subnets for Ingress ALB"
  type        = "String"
  value       = join("\\,", module.vpc.public_subnets)
}

resource "aws_ssm_parameter" "security_groups" {
  name        = "${terraform.workspace}_security_group_id"
  description = "Allow all inbound security groups"
  type        = "String"
  value       = aws_security_group.allow_all.id
}

resource "aws_ssm_parameter" "eks_wafv2_web_acl_arn" {
  name        = "${terraform.workspace}eks_cluster_arn"
  description = "ARN for the EKS Cluster"
  type        = "String"
  value       = aws_wafv2_web_acl.eks_cluster.arn
}

resource "aws_ssm_parameter" "eks_cluster_endpoint" {
  name        = "${terraform.workspace}_eks_cluster_endpoint"
  description = "AWS EKS Cluster Endpoint URL"
  type        = "String"
  value       = module.eks-cluster.cluster_endpoint
}

resource "aws_ssm_parameter" "eks_cluster_cert_auth_data" {
  name        = "${terraform.workspace}_eks_cluster_cert_auth_data"
  description = "AWS EKS Certificate Authority Data"
  type        = "String"
  value       = module.eks-cluster.cluster_certificate_authority_data
}

resource "aws_ssm_parameter" "dns_zone" {
  name        = "${terraform.workspace}_dns_zone"
  description = "Internal DNS Zone for Ingress"
  type        = "String"
  value       = local.internal_public_hosted_zone_name
}

resource "aws_ssm_parameter" "root_dns_zone" {
  name        = "${terraform.workspace}_root_dns_zone"
  description = "Root DNS Zone for Ingress"
  type        = "String"
  value       = local.root_public_hosted_zone_name
}
