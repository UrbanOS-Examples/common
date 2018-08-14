variable "region" {
  description = "The region into which to deploy the load balancer."
}
variable "vpc_id" {
  description = "The ID of the VPC into which to deploy the load balancer."
}
variable "subnet_ids" {
  description = "The IDs of the subnets for the ELB to deploy into."
  type = "list"
}

variable "component" {
  description = "The component for which the load balancer is being created."
}
variable "deployment_identifier" {
  description = "An identifier for this instantiation."
}

variable "service_name" {
  description = "The name of the service for which the ELB is being created."
}
variable "service_port" {
  description = "The port on which the service containers are listening."
  default     = 8080
}
variable "listener_ports" {
  description = "The ports on which the load balance listener is listening."
  default = [
    {
      instance_port     = 8080
      instance_protocol = "http"
      lb_port           = 80
      lb_protocol       = "http"
    },
  ]
}
variable "ingress_rules" {
  description = "The ingress rules to apply for the load balancer."
  default     = [
    {
      instance_port     = "8080"
      instance_protocol = "http"
      lb_port           = 80
      lb_protocol       = "http"
    }
  ]
}

variable "service_certificate_arn" {
  description = "The ARN of a certificate to use for TLS terminating at the ELB."
}

variable "health_check_target" {
  description = "The target to use for health checks."
  default = "HTTP:80/health"
}
variable "allow_cidrs" {
  description = "A list of CIDRs from which the ELB is reachable."
  type = "list"
}

variable "egress_cidrs" {
  description = "A list of CIDRs which the ELB can reach."
  type = "list"
  default = []
}

variable "include_public_dns_record" {
  description = "Whether or not to create a public DNS record (\"yes\" or \"no\")."
  default = "no"
}
variable "include_private_dns_record" {
  description = "Whether or not to create a private DNS record (\"yes\" or \"no\")."
  default = "yes"
}

variable "expose_to_public_internet" {
  description = "Whether or not the ELB is publicly accessible (\"yes\" or \"no\")."
  default = "no"
}

variable "idle_timeout" {
  description = "Idle Timeout is the number of seconds a connection can be idle before the load balancer closes the connection."
  default = "180"
}
