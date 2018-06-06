variable "sg_name" {
  description = "Name of the EFS"
}

variable "vpc_id" {
  description = "Name of the VPC"
}

variable "mount_target_tags" {
  description  = "Mount target tags"
  type = "map"
}

variable "subnet" {
  description  = "Subnets where the target will be mounted"
}

variable "efs_id" {
  description  = "Id of the EFS to be mounted"
}
