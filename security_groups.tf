resource "aws_security_group" "chatter" {
  name        = "chatter"
  description = "Security group for all nodes in the cluster."
  vpc_id      = "${module.vpc.vpc_id}"

  tags = {
    Name = "Ingress and egress for EKS cluster nodes."
    Description = "Security group for allowing non-EKS cluster resources to talk to the EKS cluster."
  }
}

resource "aws_security_group_rule" "chatter_egress_internet" {
  description       = "Allow nodes to egress to anywhere."
  protocol          = "-1"
  security_group_id = "${aws_security_group.chatter.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "allow_all_sg_to_eks_worker_sg_node_ports" {
  description              = "Allow load balancer resources to talk to services in the NodePort range."
  type                     = "ingress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.chatter.id}"
  source_security_group_id = "${aws_security_group.allow_all.id}"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${module.vpc.vpc_id}"

  tags = {
    Name = "Ingress and egress for load balancers."
    Description = "Security group for allowing external and internal networks to talk to load balancers."
  }

  ingress {
    description = "Allow any network to talk to load balancer via HTTP."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow any network to talk to load balancer via HTTPS."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow nodes to egress to anywhere."
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

output "chatter_sg_id" {
  description = "The common security group for intra-VPC traffic"
  value       = "${aws_security_group.chatter.id}"
}
