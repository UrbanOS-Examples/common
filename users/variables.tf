variable "region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "users" {
  description = "List of users"
  type        = "list"
}

variable "pgp_key" {
  description = "Base64 encodeded PGP public key or keybase:{username}"
  type        = "string"
  default     = "keybase:test"
}
