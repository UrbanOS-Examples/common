provider "aws" {
  region = "${var.region}"

  assume_role {
    role_arn = "${var.role_arn}"
  }
}

terraform {
  backend "s3" {
    key     = "operating-system"
    encrypt = true
  }
}

resource "aws_key_pair" "cloud_key" {
  key_name   = "${terraform.workspace}_env_cloud_key"
  public_key = "${var.key_pair_public_key}"
}

provider "random" {
    # the old kubernetes module used a module that needed the random provider.
    # Apparently, Terraform needs the plug in to delete the old cluster,
    # but since we removed the last refernce to the plug-in, it's not downloaded
    # on init.
    #
    # We can remove this provider block after module.kubernetes is removed from the remote state.
    #
    # See https://github.com/hashicorp/terraform/issues/16127
}

locals {
  kubernetes_cluster_name = "${length(var.kubernetes_cluster_name) > 0 ? var.kubernetes_cluster_name : format("%s-kube", terraform.workspace)}"
  vpc_name                = "${length(var.vpc_name) > 0 ? var.vpc_name : terraform.workspace}"
}

variable "region" {
  description = "AWS Region"
  default     = "us-west-2"
}

variable "public_dns_zone_id" {
  description = "Public DNS zone ID"
}

variable "role_arn" {
  description = "The ARN for the assumed role into the environment to be changes (e.g. dev, test, prod)"
}

variable "kubernetes_cluster_name" {
  description = "The cluster name for kubernetes"
  default     = ""
}

variable "vpc_name" {
  description = "The name of the environment VPC"
  default     = ""
}

output "key_pair_name" {
  description = "Name of the keypair to use for env deployments"
  value       = "${aws_key_pair.cloud_key.key_name}"
}

output "aws_region" {
  description = "Name of aws region"
  value       = "${var.region}"
}