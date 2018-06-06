provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
   bucket = "scos-alm-terraform-state"
   key    = "nexus_efs_mount_target"
   region = "us-east-2"
   dynamodb_table="terraform_lock"
   encrypt = "true"
   role_arn = "arn:aws:iam::199837183662:role/UpdateTerraform"
 }
}

#refer to existing VPC
data "terraform_remote_state" "vpc" {
 backend     = "s3"
 workspace = "${terraform.workspace}"

 config {
   bucket = "scos-alm-terraform-state"
   key    = "vpc"
   region = "us-east-2"
   role_arn = "arn:aws:iam::199837183662:role/UpdateTerraform"
 }
}

data "terraform_remote_state" "efs" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config {
    bucket   = "scos-alm-terraform-state"
    key      = "nexus_efs"
    region   = "us-east-2"
    role_arn = "arn:aws:iam::199837183662:role/UpdateTerraform"
  }
}

module "mount_targets" {
  source = "../../modules/efs_mount_target"
  sg_name = "nexus-data"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  mount_target_tags  = {"name" = "nexus", "environment" = "${var.environment}"}
  subnets = "${data.terraform_remote_state.vpc.private_subnets}"
  efs_id = "${data.terraform_remote_state.efs.efs_id}"
}
