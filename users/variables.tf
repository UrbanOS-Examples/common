variable "region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "users" {
  description = "List of users"
  type        = "list"

  default = [
    "cmcclellan",
    "bcromer",
    "ksmith",
    "emoore",
    "jmorris",
    "jlutz",
    "brogers",
    "smillard",
    "rsepulveda",
    "abhagat",
    "rboyapati",
    "cyeater",
    "afreeman",
    "oqi",
    "aganesh",
    "bschwanitz",
    "testuser"
  ]
}

variable "pgp_key" {
  description = "Base64 encodeded PGP public key or keybase:{username}"
  type        = "string"
  default     = "keybase:test"
}
