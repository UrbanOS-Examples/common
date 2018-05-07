provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
   bucket = "scos-terraform-state"
   key    = "efs"
   region = "us-east-2"
   dynamodb_table="terraform_lock"
   encrypt = "true"
   role_arn = "arn:aws:iam::784801362222:role/UpdateTerraform"
 }
}

# Define EFS / NFS file system at the AWS level without any mounting on EC2 instances
resource "aws_efs_file_system" "this" {
  creation_token = "${var.efs_token}"
  # Performance_mode:  generalPurpose, maxIO
  performance_mode = "${var.efs_mode}"
  encrypted = "${var.efs_encrypted}"
  tags {
    Name = "${var.efs_name}"
  }
   lifecycle {
    prevent_destroy = true
  }
}
