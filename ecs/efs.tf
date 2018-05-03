resource "aws_efs_file_system" "ecs" {
  creation_token = "${var.efs_token}"
  # Performance_mode:  generalPurpose, maxIO
  performance_mode = "${var.efs_mode}"
  encrypted = "${var.efs_encrypted}"
  tags {
    Name = "${var.efs_name}"
  }
}

resource "aws_efs_mount_target" "a" {
  file_system_id = "${aws_efs_file_system.ecs.id}"
  subnet_id      = "${var.subnet_ids[0]}"
  security_groups = [
    "${aws_security_group.ecs_sg.id}"
  ]
}

resource "aws_efs_mount_target" "b" {
  file_system_id = "${aws_efs_file_system.ecs.id}"
  subnet_id      = "${var.subnet_ids[1]}"
  security_groups = [
     "${aws_security_group.ecs_sg.id}"
  ]
}

resource "aws_efs_mount_target" "c" {
  file_system_id = "${aws_efs_file_system.ecs.id}"
  subnet_id      = "${var.subnet_ids[2]}"
  security_groups = [
     "${aws_security_group.ecs_sg.id}"
  ]
}
