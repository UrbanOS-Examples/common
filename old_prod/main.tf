provider "aws" {
  region = "${var.aws_region}"
  version = "1.28.0"
  assume_role {
    role_arn = "${var.aws_role_arn}"
  }
}

terraform {
  backend "s3" {
    key     = "old_prod"
    encrypt = true
  }
}

variable "aws_region" {
  description = "Region for old prod to be deployed to"
  default     = "us-east-1"
}

variable "aws_role_arn" {
  description = "ARN of IAM role to assume for accessing the old prod subaccount"
  default     = "arn:aws:iam::374013108165:role/dev_view_only_role"
}
