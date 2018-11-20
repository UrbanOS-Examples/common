output "hive_db_endpoint" {
  description = "The FQDN:Port of the Hive RDS database."
  value       = "${aws_db_instance.hive_db.endpoint}"
}

output "ranger_db_endpoint" {
  description = "The FQDN:Port of the Ranger RDS database."
  value       = "${aws_db_instance.ranger_db.endpoint}"
}

output "blueprint_name" {
  description = "The name of the blueprint that is deployed for a given blueprint iteration."
  value       = "${local.ambari_blueprint_name}"
}

output "cluster_name" {
  description = "The name of the cluster resulting from a given deployment with unique value hashing."
  value       = "${local.cluster_name}"
}

output "rendered_cluster_template" {
  description = "The rendered output of the terraform variables fed to the cluster_template.tpl"
  value       = "${data.template_file.cloudbreak_cluster.rendered}"
}

output "ambari_admin_password_id" {
  description = "The resource ID of the ambari admin password"
  value       = "${aws_secretsmanager_secret_version.ambari_admin_password.arn}"
}

output "public_hosted_zone_id" {
  description = "The Zone ID of the public route53 zone"
  value       = "${aws_route53_zone.public_hosted_zone.id}"
}
