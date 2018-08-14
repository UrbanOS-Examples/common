output "name" {
  description = "The name of the created ELB."
  value = "${aws_elb.service.name}"
}

output "arn" {
  description = "The ARN of the created ELB."
  value = "${aws_elb.service.arn}"
}

output "dns_name" {
  description = "The DNS name of the created ELB."
  value = "${aws_elb.service.dns_name}"
}

output "security_group_id" {
  description = "The ID of the security group associated with the ELB."
  value = "${aws_security_group.load_balancer.id}"
}
