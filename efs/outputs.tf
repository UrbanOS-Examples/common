# VPC
output "efs_id" {
  description = "The ID of the EFS"
  value       = "${aws_efs_file_system.this.id}"
}

output "kms_key_id" {
  description = "The ARN for the KMS encryption key"
  value       = "${aws_efs_file_system.this.kms_key_id}"
}

output "dns_name" {
  description = "The DNS name for the filesystem"
  value       = "${aws_efs_file_system.this.dns_name}"
}
