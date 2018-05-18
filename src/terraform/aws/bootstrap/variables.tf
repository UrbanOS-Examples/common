variable "region" {
  description = "AWS Region"
  default     = "us-east-2"
}

variable "bucket_name" {
  description = "AWS S3 bucket name for Terraform state"
  default     = "scos-alm-terraform-state"
}

variable "lock_table_name" {
  description = "Name for lock table in DynamoDB"
  default     = "terraform_lock"
}
