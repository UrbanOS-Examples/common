provider "aws" {
  region = "${var.region}"

  assume_role {
    role_arn = "${var.role_arn}"
  }
}

terraform {
  backend "s3" {
    bucket         = "scos-sandbox-terraform-state"
    key            = "operating-system"
    region         = "us-east-2"
    dynamodb_table = "terraform_lock"
    encrypt        = true
  }
}

resource "aws_key_pair" "cloud_key" {
  key_name   = "${terraform.workspace}_env_cloud_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRAvH6k7iEeRDz9SQtkH1o8KiUaed/e2hmzTUjA8bhmeWVLPsgCMKIUKR0jdPlvdZ0AmMLXswobsXj08dPgWxUZxoAWIqKCjd969KckydUpBtcb+X2Q+tpOcugBOQSY1H8hgNrdcRKEaUllTfvseJ9pBOYU7j9VuZ608HQhfZw7+aS8wi9o/BJwejtpWdlo6gkxXoIRqDX/ioYg+W6Tc7yoUzAEANwZAy3/3GKWDrh+9jnzR6mEEN48Nuee49wWfP5G0T/v4+Gvux5zioHb3rcmmR9YTkFOiv1poInhXlPdc7Q38yj+z6E+hACNN3rK80YjU0ByaSPltPjqm9ZYmPX"
}

variable "region" {
  description = "AWS Region"
  default     = "us-east-2"
}

variable "role_arn" {
  description = "The ARN for the assumed role into the environment to be changes (e.g. dev, test, prod)"
}

variable "environment" {
  description = "VPC environment. It can be sandbox, dev, staging or production"
  default     = ""
}