module "efs" {
  source = "../modules/efs"

  efs_name = "${var.efs_name}"
  efs_mode = "${var.efs_mode}"
  efs_encrypted = "${var.efs_encrypted}"
}
