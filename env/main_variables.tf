variable "region" {
  description = "AWS Region"
  default     = "us-east-2"
}

variable "role_arn" {
  description = "The ARN for the assumed role into the environment to be changes (e.g. dev, test, prod)"
}

variable "owner" {
  description = "User creating this VPC. It should be done through jenkins"
  default     = "jenkins"
}

variable "vpc_name" {
  description = "The name of the VPC"
}

variable "vpc_single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "environment" {
  description = "VPC environment. It can be sandbox, dev, staging or production"
  default     = ""
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "A list of availability zones in the region"
  default     = ["us-east-2a"]
}

variable "vpc_private_subnets" {
  description = "CIDR blocks for Private Subnets"
  default     = ["10.0.0.0/19"]
}

variable "vpc_public_subnets" {
  description = "CIDR blocks for Public Subnets"
  default     = ["10.0.32.0/20"]
}

variable "vpc_enable_nat_gateway" {
  description = "Provision NAT Gateways for each of your availability zones"
  default     = true
}

variable "vpc_enable_vpn_gateway" {
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
  default     = true
}

variable "vpc_enable_s3_endpoint" {
  description = "Should be true if you want to provision an S3 endpoint to the VPC"
  default     = true
}

variable "vpc_enable_dynamodb_endpoint" {
  description = "Should be true if you want to provision a DynamoDB endpoint to the VPC"
  default     = true
}

variable "vpc_enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = true
}

variable "dns_zone_name" {
  description = "Name of public and private DNS Route53 zone"
}

variable "kubernetes_cluster_name" {
  description = "Name of the Kubernetes Cluster"
}

variable "min_worker_count" {
  description = "Minimum kubernetes workers"
  default     = 5
}

variable "max_worker_count" {
  description = "Maximum kubernetes worker"
  default     = 5
}

variable "kube_key" {
  description = "The SSH key to use for kubernetes hosts"
  default     = "./k8_rsa.pub"
}

variable "public_dns_zone_id" {
  description = "Public DNS Zone Id.  This goes away after the public zone is terraformed."
}
