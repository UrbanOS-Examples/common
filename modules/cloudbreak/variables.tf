locals {
  cb_credential_name       = "cb-credential"   // at present we don't trigger updates based on IAM changes
  cluster_subnet           = "${random_shuffle.private_subnet.result[0]}"
  start_cloudbreak_path   = "${path.module}/templates/start_cloudbreak.sh"
  update_credentials_path = "${path.module}/templates/update_credentials.sh"
}

variable "vpc_id" {
  description = "The VPC to deploy the datalake into."
}

variable "subnets" {
  description = "List of subnets to deploy the datalake into."
  type        = "list"
}

variable "remote_management_cidr" {
  description = "CIDR block of the ALM network."
}

variable "alb_certificate" {
  description = "ALB certificate to attach to the Cloudbreak load balancer."
}

variable "cloudbreak_dns_zone_id" {
  description = "DNS public zone to create the cloudbreak A record."
}

variable "cloudbreak_dns_zone_name" {
  description = "Name of the DNS public zone"
}

variable "cloudbreak_db_multi_az" {
  description = "Should the Cloudbreak DB be multi-az?"
  default     = true
}

variable "cloudbreak_db_apply_immediately" {
  description = "Should changes to the Cloudbreak DB be applied immediately?"
  default     = false
}

variable "ssh_key" {
  description = "The SSH key to inject into the cloudbreak instance."
}

variable "cloudbreak_version" {
  description = "The version of Cloudbreak to pack into the AMI."
  default     = "2.8.0"
}

variable "cloudbreak_tag" {
  description = "The released version of a Cloudbreak AMI to use"
  default     = "1.0.0"
}

