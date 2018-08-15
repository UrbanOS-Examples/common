# Define EFS / NFS file system at the AWS level without any mounting on EC2 instances
resource "aws_efs_file_system" "this" {
  creation_token = "${var.environment}-${var.efs_name}-token"

  # Performance_mode:  generalPurpose, maxIO
  performance_mode = "${var.efs_mode}"
  encrypted        = "${var.efs_encrypted}"

  tags {
    Name = "${var.environment}-${var.efs_name}"
  }

  lifecycle {
    prevent_destroy = "true"
  }
}
