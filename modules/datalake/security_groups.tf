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
    security_groups = ["${var.cloudbreak_security_group}"]
    description     = "All inbound from the Hadoop Master nodes"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "datalake-worker-${terraform.workspace}"
  }
}

resource "aws_security_group" "datalake_master" {
  name_prefix = "datalake_master_"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "datalake-master-${terraform.workspace}"
  }
}

resource "aws_security_group_rule" "hdp_allow_mgmt_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  description       = "Allow traffic from self"
  security_group_id = "${aws_security_group.datalake_master.id}"
}

resource "aws_security_group_rule" "hdp_allow_mgmt_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.remote_management_cidr}"]
  description       = "Allow internal ssh"
  security_group_id = "${aws_security_group.datalake_master.id}"
}

resource "aws_security_group_rule" "hdp_allow_mgmt_grafana" {
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["${var.remote_management_cidr}"]
  description       = "Allow Grafana UI"
  security_group_id = "${aws_security_group.datalake_master.id}"
}

resource "aws_security_group_rule" "hdp_allow_mgmt_ambari_https" {
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  cidr_blocks       = ["${var.remote_management_cidr}"]
  description       = "Allow internal https"
  security_group_id = "${aws_security_group.datalake_master.id}"
}

resource "aws_security_group_rule" "hdp_allow_mgmt_ambari_http" {
  type              = "ingress"
  from_port         = 8088
  to_port           = 8088
  protocol          = "tcp"
  cidr_blocks       = ["${var.remote_management_cidr}"]
  description       = "Allow internal resource manager"
  security_group_id = "${aws_security_group.datalake_master.id}"
}

resource "aws_security_group_rule" "hdp_cloudbreak_to_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${var.cloudbreak_security_group}"
  description              = "All inbound from the Hadoop Master nodes"
  security_group_id        = "${aws_security_group.datalake_master.id}"
}

resource "aws_security_group_rule" "hdp_master_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.datalake_master.id}"
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

// The following group needs to be converted to a rule attached to the db_allow_hadoop group created in the cloudbreak module
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
    security_groups = ["${aws_security_group.datalake_master.id}", "${var.cloudbreak_security_group}"]
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

resource "aws_security_group" "ranger_security_group" {
  name   = "Ranger Security Group"
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

resource "aws_security_group" "datalake_metrics" {
  name_prefix = "datalake_metrics_"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 6188
    to_port   = 6188
    protocol  = "tcp"
    security_groups = ["${var.eks_worker_node_security_group}"]
    description = "Allow traffic from EKS for metric visualization"
  }

  tags {
    Name = "datalake-metrics-${terraform.workspace}"
  }
}
