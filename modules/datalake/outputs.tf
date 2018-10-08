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

output "hive_db_endpoint" {
  description = "The FQDN:Port of the Hive RDS database."
  value       = "${aws_db_instance.hive_db.endpoint}"
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