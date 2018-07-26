variable "db_storage_size" {
  description = "Size in Gibibytes. Min 20 Gib"
  type        = "string"
}

variable "db_instance_class" {
  description = "AWS db instance type. db.t2.micro, db.t2.large, etc."
  type        = "string"
}

variable "db_user" {
  description = "DB User"
  default     = "joomla"
}

variable "db_password" {
  description = "DB Password"
}
