variable "region" {
  description = "AWS Region"
  default     = "us-west-2"
}

variable "alm_region" {
  description = "AWS Region"
  default     = "us-east-2"
}

variable "role_arn" {
  description = "The ARN for the assumed role into the environment to be changes (e.g. dev, test, prod)"
}

variable "alm_role_arn" {
  description = "The ARN for the assumed role into the Application LifeCycle Management environment"
}

variable "vpc_id" {
  description = "VPC Id"
}

variable "alm_vpc_id" {
  description = "VCP Id of the Application LifeCycle Management network"
}

variable "public_subnet_ids" {
  description = "Public subnet ids"
  type        = "list"
}

variable "private_subnet_ids" {
  description = "Private subnet ids"
  type        = "list"
}

variable "alm_account_id" {
  description = "Account ID of the Elastic Container Repository to use for custom images"
}

variable "joomla_public_key" {
  description = "Public key"
}

variable "cluster_instance_type" {
  description = "The instance type of the container instances"
  default     = "t2.medium"
}

variable "memory" {
  description = "Memory"
}
