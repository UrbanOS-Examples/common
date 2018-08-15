module "jenkins_efs" {
  source = "../modules/efs"

  efs_name      = "jenkins"
  efs_mode      = "generalPurpose"
  efs_encrypted = true

  environment   = "${var.environment}"
}

output "jenkins_efs_dns_name" {
  value = "${module.jenkins_efs.dns_name}"
}

output "jenkins_efs_id" {
  value = "${module.jenkins_efs.efs_id}"
}
