provider "aws" {
  version = "1.39"
  region  = "us-east-2"

  assume_role {
    role_arn = "${var.alm_role_arn}"
  }
}

terraform {
  backend "s3" {
    key     = "alm-durable"
    encrypt = true
  }
}

variable "alm_role_arn" {
  description = "ALM role to assume"
}

variable "environment" {
  description = "Name of the environment being deployed"
}
