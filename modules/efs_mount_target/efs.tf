# Security group EFS access
resource "aws_security_group" "this" {
  name = "${var.sg_name}-EFS-Security Group"
  description = "Access to ports EFS (2049)"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Open to incoming EFS traffic from App instances"
  }

  ingress {
    from_port = 111
    to_port = 111
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Open to incoming EFS traffic from App instances"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Open to all outgoing traffic"
  }

  tags = "${merge(var.mount_target_tags, map("Name", "${var.sg_name} EFS"))}"
}

#Terraform Does not support an array for "subnet_id" by now create 3 targets should be used instead.
resource "aws_efs_mount_target" "this" {
  count = "${length(var.subnets)}"
  file_system_id = "${var.efs_id}"
  subnet_id      = "${element(var.subnets, count.index)}"
  security_groups  = ["${aws_security_group.this.id}"]
}
