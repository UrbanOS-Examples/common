provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
   bucket = "scos-sandbox-terraform-state"
   key    = "nexus"
   region = "us-east-2"
   dynamodb_table="terraform_lock"
   encrypt = "true"
 }
}

data "terraform_remote_state" "vpc" {
 backend     = "s3"
 workspace = "${terraform.workspace}"

 config {
   bucket = "scos-sandbox-terraform-state"
   key    = "alm"
   region = "us-east-2"
 }
}
