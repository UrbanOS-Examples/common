resource "aws_security_group" "chatter" {
  name        = "chatter"
  description = "Security group for all nodes in the cluster."
  vpc_id      = "${module.vpc.vpc_id}"

  tags = {
    Name = "Egress and internal chatter"
  }
}

resource "aws_security_group_rule" "chatter_egress_internet" {
  description       = "Allow nodes to egress to the Internet."
  protocol          = "-1"
  security_group_id = "${aws_security_group.chatter.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "chatter_ingress_self" {
  description              = "Allow nodes to communicate with each other."
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.chatter.id}"
  source_security_group_id = "${aws_security_group.chatter.id}"
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "allow_all_sg_to_eks_worker_sg" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.chatter.id}"
  source_security_group_id = "${aws_security_group.allow_all.id}"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "os_servers" {
  name   = "OS Servers"
  vpc_id = "${module.vpc.vpc_id}"

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
    cidr_blocks = ["${data.terraform_remote_state.alm_remote_state.vpc_cidr_block}"]
    description = "Allow all traffic from admin VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "allow_all_security_group" {
  description = "Security group id to allow all traffic to access albs"
  value       = "${aws_security_group.allow_all.id}"
}

output "os_servers_sg_id" {
  value = "${aws_security_group.os_servers.id}"
}

output "chatter_sg_id" {
  description = "The common security group for intra-VPC traffic"
  value       = "${aws_security_group.chatter.id}"
}
