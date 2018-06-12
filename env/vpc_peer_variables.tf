variable "alm_role_arn" {
  description = "The ARN for the assume role for ALM access"
}

variable "alm_account_id" {
  description = "Id if the account to peer to"
}

variable "alm_state_bucket" {
  description = "S3 Bucket which contains the ALM terraform state"
  default     = "scos-sandbox-terraform-state"
}

variable "alm_workspace" {
  description = "Workspace for the ALM state"
}

variable "accepter_credentials_profile" {
    description = "The AWS credentials profile to use for accepting peering"
}
