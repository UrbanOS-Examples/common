output "cloudbreak_instance" {
  description = "The IP address of the resulting cloudbreak server."
  value       = "${aws_instance.cloudbreak.private_ip}"
}

output "cloudbreak_hostname" {
  description = "The FQDN of the resulting cloudbreak server."
  value       = "${aws_route53_record.cloudbreak_public_dns.fqdn}"
}

output "cloudbreak_db_endpoint" {
  description = "The FQDN:Port of the Cloudbreak RDS database."
  value       = "${aws_db_instance.cloudbreak_db.endpoint}"
}

output "cloudbreak_security_group" {
  description = "The id of the cloudbreak instance security group"
  value       = "${aws_security_group.cloudbreak_security_group.id}"
}

output "cloudbreak_credential_name" {
  description = "The name of the IAM credential to attach to the clusters."
  value       = "${local.cb_credential_name}"
}

output "cloudbreak_ready" {
  description = "A reasonably decent signal that cloudbreak is ready for use"
  value       = "${null_resource.cloudbreak.id}"
}
