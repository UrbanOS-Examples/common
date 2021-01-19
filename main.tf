terraform {
  required_version = "= 0.11.11"

  backend "s3" {
    key     = "operating-system"
    encrypt = true
  }
}

data "terraform_remote_state" "alm_remote_state" {
  backend   = "s3"
  workspace = "${var.alm_workspace}"

  config {
    bucket   = "${var.alm_state_bucket_name}"
    key      = "alm"
    region   = "us-east-2"
    role_arn = "${var.alm_role_arn}"
  }
}

data "terraform_remote_state" "durable" {
  backend   = "s3"
  workspace = "${var.alm_workspace}"

  config {
    bucket   = "${var.alm_state_bucket_name}"
    key      = "alm-durable"
    region   = "us-east-2"
    role_arn = "${var.alm_role_arn}"
  }
}

data "aws_caller_identity" "current" {}

resource "random_pet" "this_exists_to_download_random_plugin_if_terraform_cache_is_removed" {}

resource "aws_key_pair" "cloud_key" {
  key_name   = "${var.key_pair_name}"
  public_key = "${var.key_pair_public_key}"
}

locals {
  vpc_name                = "${length(var.vpc_name) > 0 ? var.vpc_name : terraform.workspace}"
  kubernetes_cluster_name = "streaming-kube-${terraform.workspace}"
}

variable "region" {
  description = "AWS Region"
  default     = "us-west-2" # If changing regions see comments below
}
# See here for details about AWS inspector package rules: https://docs.aws.amazon.com/inspector/latest/userguide/inspector_rules-arns.html

variable "role_arn" {
  description = "The ARN for the assumed role into the environment to be changes (e.g. dev, test, prod)"
}

variable "vpc_name" {
  description = "The name of the environment VPC"
  default     = ""
}

variable "is_sandbox" {
  description = "True disables public DNS records for sandbox domains to prevent terraform failues for certificate validation. This should always be true in Sandbox."
  default     = false
}

variable "force_destroy_s3_bucket" {
  description = "A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default       = false
}

output "key_pair_name" {
  description = "Name of the keypair to use for env deployments"
  value       = "${aws_key_pair.cloud_key.key_name}"
}

output "aws_region" {
  description = "Name of aws region"
  value       = "${var.region}"
}

variable "andi_public_sample_datasets" {
  description = "Bucket for public sample datasets in andi"
  default     = "andi-public-sample-datasets"
}
