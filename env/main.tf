provider "aws" {
  version = "1.39"
  region  = "${var.region}"

  assume_role {
    role_arn = "${var.role_arn}"
  }
}

provider "aws" {
  version = "1.39"
  alias   = "alm"
  region  = "${var.alm_region}"

  assume_role {
    role_arn = "${var.alm_role_arn}"
  }
}
terraform {
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

resource "random_pet" "rebuild_again_please" {}

resource "aws_key_pair" "cloud_key" {
  key_name   = "${terraform.workspace}_env_cloud_key"
  public_key = "${var.key_pair_public_key}"
}

locals {
  vpc_name = "${length(var.vpc_name) > 0 ? var.vpc_name : terraform.workspace}"
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

variable "skip_final_db_snapshot" {
  description = "Should the databases take a final snapshot or not"
  default     = false
}

variable "recovery_window_in_days" {
  description = "How long to allow secrets to be recovered if they are deleted"
  default     = 30
}

variable "is_public_facing" {
  description = "false to utilize private/internal loadbalancers; true to use public"
}

output "key_pair_name" {
  description = "Name of the keypair to use for env deployments"
  value       = "${aws_key_pair.cloud_key.key_name}"
}

output "aws_region" {
  description = "Name of aws region"
  value       = "${var.region}"
}