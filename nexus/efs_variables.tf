# ------------- EFS -----------------------------
variable "efs_name" {
  description = "EFS name"
  default = "nexus"
}

variable "efs_mode" {
  description = "xfer mode:  generalPurpose OR maxIO"
  default = "generalPurpose"
}

variable "efs_encrypted" {
  description = "Is EFS encrypted?  true/false"
  type = "string"
  default = true
}
