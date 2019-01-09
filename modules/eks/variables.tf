variable "cluster_version" {
  description = "The version of k8s at which to install the cluster"
  default     = "1.10"
}

variable "k8s_instance_size" {
  description = "EC2 instance type"
  default = "t3.large"
}

variable "min_num_of_workers" {
  description = "Minimum number of workers to be created on eks cluster"
  default = 2
}

variable "max_num_of_workers" {
  description = "Maximum number of workers to be created on eks cluster"
  default = 4
}

variable "public_subnets" {
    type        = "list"
    description = "list of public subnets on the VPC to attach EKS to"
}

variable "vpc_id" {
    description = "AWS resouce ID of the VPC to attach EKS to"
}

variable "role_arn" {
    description = "AWS role ARN to use to deploy the EKS cluster"
}

variable "chatter_sg_arn" {
    description = "AWS ARN for chatter security group"
}

variable "allow_all_sg_arn" {
    description = "AWS ARN for allow all security group"
}

variable "cloud_key_name" {}

variable "tls_cert_arn" {
    description = "AWS ARN for TLS certificate used by load balancers deployed by EKS"
}

variable "internal_public_hosted_zone_name" {}

variable "region" {
    description = "AWS region for EKS cluster"
}