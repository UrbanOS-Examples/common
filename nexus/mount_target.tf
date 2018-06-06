module "mount_targets" {
  source = "../modules/efs_mount_target"
  sg_name = "nexus-data"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  mount_target_tags  = {"name" = "nexus", "environment" = "${var.environment}"}
  subnet = "${data.terraform_remote_state.vpc.private_subnets[0]}"
  efs_id = "${module.efs.efs_id}"
}
