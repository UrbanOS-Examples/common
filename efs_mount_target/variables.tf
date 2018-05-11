variable "sg_name" {
  description = "Name of the EFS"
}

variable "vpc_id" {
  description = "Name of the VPC"
}

variable "mount_target_tags" {
  description  = "Mount target tags"
  type = "map"
  default = {}
}

variable "subnets" {
  description  = "Subnets where the target will be mounted"
  type = "list"
}

variable "efs_id" {
  description  = "Id of the EFS to be mounted"
}
