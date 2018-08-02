locals {
  alm_private_zone_id = "${data.terraform_remote_state.alm_remote_state.private_zone_id}"
}

provider "aws" {
  alias  = "alm"
  region = "${var.alm_region}"

  assume_role {
    role_arn = "${var.alm_role_arn}"
  }
}

data "terraform_remote_state" "alm_remote_state" {
  backend   = "s3"
  workspace = "${var.alm_workspace}"

  config {
    bucket   = "${var.alm_state_bucket_name}"
    key      = "alm"
    region   = "us-east-2"
    role_arn = "${var.terraform_state_role_arn}"
  }
}

variable "alm_role_arn" {
  description = "The ARN for the assume role for ALM access"
  default     = "arn:aws:iam::199837183662:role/jenkins_role"
}

variable "alm_state_bucket_name" {
  description = "The name of the S3 state bucket for ALM"
  default     = "scos-alm-terraform-state"
}

variable "alm_workspace" {
  description = "Workspace for the ALM state"
  default     = "alm"
}

variable "alm_region" {
  description = "AWS Region of ALM Environment"
  default     = "us-east-2"
}
