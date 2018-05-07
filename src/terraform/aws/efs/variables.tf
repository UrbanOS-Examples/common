
# ------------- EFS -----------------------------
variable "region" {
  description = "AWS region"
  default = "us-east-2"
}

variable "efs_name" {
  description = "EFS name"
}

variable "efs_token" {
  description = "EFS Token, whatever that is...."
}

variable "efs_mode" {
  description = "xfer mode:  generalPurpose OR maxIO"
}

variable "efs_encrypted" {
  description = "Is EFS encrypted?  true/false"
  type = "string"
}
