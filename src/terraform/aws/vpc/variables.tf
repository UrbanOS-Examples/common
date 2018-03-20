variable "region" {
  description = "AWS Region"
  default     = "us-east-2"
}

variable "owner" {
  description = "User creating this VPC. It should be done through jenkins"
  default     = "jenkins"
}

variable "name" {
  description = "The name of the VPC"
  default     = ""
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "environment" {
  description = "VPC environment. It can be sandbox, dev, staging or production"
  default     = ""
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "A list of availability zones in the region"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}


variable "private_subnets" {
  description = "CIDR blocks for Private Subnets"
  default     = ["10.0.0.0/19", "10.0.64.0/19", "10.0.128.0/19"]
}

variable "protected_subnets" {
  description = "CIDR blocks for Protected Subnets"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "public_subnets" {
  description = "CIDR blocks for Public Subnets"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "enable_nat_gateway" {
  description = "Provision NAT Gateways for each of your availability zones"
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
  default     = true
}

variable "enable_s3_endpoint" {
  description = "Should be true if you want to provision an S3 endpoint to the VPC"
  default     = true
}

variable "enable_dynamodb_endpoint" {
  description = "Should be true if you want to provision a DynamoDB endpoint to the VPC"
  default     = true
}
