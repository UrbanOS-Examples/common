# Security group EFS access
resource "aws_security_group" "this" {
  name = "${var.name}-EFS-Security Group"
  description = "Access to ports EFS (2049)"
  vpc_id = "${aws_vpc.this.id}"

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

  tags = "${merge(var.tags, map("Name", "${var.name} EFS"))}"
}

#Terraform Does not support an array for "subnet_id" by now create 3 targets should be used instead.
resource "aws_efs_mount_target" "this" {
  count = "${length(aws_subnet.private.*.id)}"
  file_system_id = "${var.efs_id}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  security_groups  = ["${aws_security_group.this.id}"]
}
