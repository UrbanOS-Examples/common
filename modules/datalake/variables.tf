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

variable "cloudbreak_dns_zone" {
  description = "DNS public zone to create the cloudbreak A record."
}

variable "cloudbreak_db_multi_az" {
  description = "Should the Cloudbreak DB be multi-az?"
  default     = true
}

variable "cloudbreak_db_apply_immediately" {
  description = "Should changes to the Cloudbreak DB be applied immediately?"
  default = false
}

variable "ssh_key" {
  description = "The SSH key to inject into the cloudbreak instance."
}

variable "cloudbreak_version" {
  description = "The version of Cloudbreak to pack into the AMI."
  default = "2.7.1"
}

variable "cloudbreak_tag" {
  description = "The released version of a Cloudbreak AMI to use"
  default = "1.0.0"
}

variable "hive_db_multi_az" {
  description = "Should the Hive DB be multi-az?"
  default     = true
}

variable "hive_db_apply_immediately" {
  description = "Should changes to the Hive DB be applied immediately?"
  default = false
}
