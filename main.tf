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

resource "random_pet" "this_exists_to_download_random_plugin_if_terraform_cache_is_removed" {}

resource "aws_key_pair" "cloud_key" {
  key_name   = "${terraform.workspace}_env_cloud_key_20200121"
  public_key = "${var.key_pair_public_key}"
}

locals {
  vpc_name                = "${length(var.vpc_name) > 0 ? var.vpc_name : terraform.workspace}"
  kubernetes_cluster_name = "streaming-kube-${terraform.workspace}"
}

variable "region" {
  description = "AWS Region"
  default     = "us-west-2"
}

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

output "key_pair_name" {
  description = "Name of the keypair to use for env deployments"
  value       = "${aws_key_pair.cloud_key.key_name}"
}

output "aws_region" {
  description = "Name of aws region"
  value       = "${var.region}"
}
