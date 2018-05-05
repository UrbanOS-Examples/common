variable "cluster_name" {
  description = "The name of your ECS cluster"
}

variable "role_name" {
  description = "Role , Name"
}

variable "role_policy_name" {
  description = "Role Policy Name"
}

variable "instance_profile_name" {
  description = "EC2 Instance Profile Name"
}

variable "type" {
  description = "EC2 Instance Type"
}

variable "cluster_max_size" {
  description = "Max number of EC2 instances in the cluster"
}

variable "cluster_min_size" {
  description = "Min number of EC2 instances in the cluster"
}

variable "subnet_ids" {
  description = "List of subnet IDs to use when spinning up your cluster"
  type = "list"
}

variable "key_name" {
  description = "AWS Key Pair to use for instances in the cluster"
}

variable "vpc_id" {
  description = "This is the ID of the VPC you want to use"
}

variable "container_name" {
  description = "AWS load balancer container name for ECS service"
}

# ------------------------------------
# START OF NEW VARIABLES FOR ECS SERVICE/TASKS

# AMI ECS image values/filter
variable "ami_filter" {
  description = "AMI ECS image filter"
  type = "string"
#  default = ["*-amazon-ecs-optimized"]
}

variable "ecs_task_def_name" {
  description = "ECS task definition name"
  type = "string"
}

variable "ecs_task_def_docker_image" {
  description = "ECS task definition docker image"
  type = "string"
}

variable "ecs_task_def_cpu_units" {
  description = "ECS task def's cpu units"
  type = "string"
}

variable "ecs_task_def_memory_units" {
  description = "ECS task def's memory units"
  type = "string"
}

variable "ecs_task_def_memory_reservation" {
  description = "ECS task def's memory reservation"
  type = "string"
}

variable "ecs_service_name" {
  description = "ECS service name"
  type = "string"
}

variable "ecs_service_tasks_desired_count" {
  description = "Desired number of tasks running for the service"
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

variable "launch_control_public_ip" {
  description = "True/false for defining EC2 public ip address"
}
