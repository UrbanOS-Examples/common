# ------------- EFS -----------------------------
variable "region" {
  description = "AWS region"
  default = "us-east-2"
}

variable "efs_name" {
  description = "EFS name"
}

variable "efs_mode" {
  description = "xfer mode:  generalPurpose OR maxIO"
}

variable "efs_encrypted" {
  description = "Is EFS encrypted?  true/false"
  type = "string"
}

variable "prevent_destroy" {
  description = "The switch to override prevent destroy"
  default = "true"
}
