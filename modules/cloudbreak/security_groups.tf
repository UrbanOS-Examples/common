resource "aws_security_group" "cloudbreak_security_group" {
  name   = "Cloudbreak Security Group"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "cloudbreak-${terraform.workspace}"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow traffic from self"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.remote_management_cidr}"]
    description = "Allow all traffic from admin VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_allow_hadoop" {
  name_prefix = "db_allow_hadoop"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "Postgres Allow Hadoop"
  }

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = ["${aws_security_group.cloudbreak_security_group.id}"]
    description = "Allow postgres traffic from Hadoop"
  }
}

