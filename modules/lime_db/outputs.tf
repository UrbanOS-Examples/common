output "lime_db_address" {
  description = "The FDQN of the Lime RDS instance"
  value       = "${aws_db_instance.lime_db.address}"
}

output "lime_db_port" {
  description = "The Port of the Lime RDS database."
  value       = "${aws_db_instance.lime_db.port}"
}

output "lime_db_password_id" {
  description = "The resource ID of the lime db password."
  value       = "${aws_secretsmanager_secret_version.lime_db_password.arn}"
}
