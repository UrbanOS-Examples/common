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

