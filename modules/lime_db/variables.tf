variable "app_compute_security_group" {
  description = "The security group of the infrastructure running the lime app."
}


variable "vpc_id" {
  description = "The vpc into which the database is deployed"
}

variable "subnets" {
  description = "List of subnets to deploy the lime db into."
  type        = "list"
}

variable "lime_db_name" {
  description = "The name of the engine's default database."
  default     = "lime_survey"
}

variable "lime_db_size" {
  description = "The ec2 instance size to assign to the db."
  default     = "db.t2.small"
}

variable "lime_db_storage" {
  description = "The disk size, in gigabytes to assign to the lime rds."
  default     = 100
}

variable "lime_db_multi_az" {
  description = "Should the Lime DB be multi-az?"
  default     = true
}

variable "lime_db_apply_immediately" {
  description = "Should changes to the Lime DB be applied immediately?"
  default     = true
}

variable "final_db_snapshot" {
  description = "Should the databases take a final snapshot or not?"
  default     = false
}

variable "secret_recovery_window" {
  description = "How long to allow secrets to be recovered if they are deleted"
  default     = 0
}
