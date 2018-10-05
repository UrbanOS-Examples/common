resource "aws_security_group" "cloudbreak_security_group" {
  name   = "Cloudbreak Security Group"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "Cloudbreak"
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

resource "aws_security_group" "datalake_worker" {
  name_prefix = "datalake_worker_"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["${var.remote_management_cidr}"]
    description = "Allow internal ssh"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow traffic from self"
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.datalake_master.id}"]
    description     = "All inbound from the Hadoop Master nodes"
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.cloudbreak_security_group.id}"]
    description     = "All inbound from the Hadoop Master nodes"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "datalake worker"
  }
}

resource "aws_security_group" "datalake_master" {
  name_prefix = "datalake_master_"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "datalake master"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow traffic from self"
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["${var.remote_management_cidr}"]
    description = "Allow internal ssh"
  }

  ingress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    cidr_blocks = ["${var.remote_management_cidr}"]
    description = "Allow Grafana UI"
  }

  ingress {
    from_port = 8443
    to_port   = 8443
    protocol  = "tcp"
    cidr_blocks = ["${var.remote_management_cidr}"]
    description = "Allow internal https"
  }

  ingress {
    from_port = 8088
    to_port   = 8088
    protocol  = "tcp"
    cidr_blocks = ["${var.remote_management_cidr}"]
    description = "Allow internal resource manager"
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.cloudbreak_security_group.id}"]
    description     = "All inbound from the Hadoop Master nodes"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "hdp_worker_to_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.datalake_worker.id}"
  description              = "All inbound from the Hadoop Workers back to the Masters"
  security_group_id        = "${aws_security_group.datalake_master.id}"
}

resource "aws_security_group" "postgres_allow_hdpdbs" {
  name_prefix = "postgres_allow_hdp"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "Postgres Allow Hadoop"
  }

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = ["${aws_security_group.cloudbreak_security_group.id}", "${aws_security_group.datalake_master.id}"]
    description = "Allow postgres traffic from Hadoop"
  }
}

resource "aws_security_group" "hive_security_group" {
  name   = "Hive Security Group"
  vpc_id = "${var.vpc_id}"

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
