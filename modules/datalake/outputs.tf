output "hive_metastore_address" {
  description = "The address of the Hive meta database."
  value       = "${aws_db_instance.hive_db.address}"
}

output "hive_metastore_url" {
  description = "The URL of the Hive metastore database."
  value       = "jdbc:postgresql://${aws_db_instance.hive_db.endpoint}/hive?createDatabaseIfNotExist=true"
}

output "hive_metastore_username" {
  value = "${aws_db_instance.hive_db.username}"
}

output "hive_metastore_password" {
  sensitive = true
  value = "${aws_db_instance.hive_db.password}"
}

output "hive_metastore_password_secret_id" {
  value = "${aws_secretsmanager_secret_version.hive_db_password.arn}"
}

output "hive_thrift_address" {
  description = "The address of the Hive database."
  value = "${aws_route53_record.datalake_hive_dns.fqdn}"
}

output "hive_thrift_url" {
  description = "The URL of the Hive database."
  value = "jdbc:hive2://${aws_route53_record.datalake_hive_dns.fqdn}:10000/hive;auth=noSasl"
}

output "hive_thrift_username" {
  value = "hive"
}

output "hive_thrift_password" {
  sensitive = true
  value = ""
}

output "hive_thrift_password_secret_id" {
  value = "${aws_secretsmanager_secret_version.hive_thrift_password.arn}"
}

output "master_address_list" {
  value = [
    "${aws_route53_record.datalake_master-namenode1_dns.fqdn}",
    "${aws_route53_record.datalake_master-namenode2_dns.fqdn}"
  ]
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
