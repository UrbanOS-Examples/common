resource "aws_security_group" "chatter" {
  name        = "chatter"
  description = "Security group for all nodes in the cluster."
  vpc_id      = "${module.vpc.vpc_id}"

  tags = {
    Name        = "Ingress and egress for EKS cluster nodes."
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
    Name        = "Ingress and egress for load balancers."
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

resource "aws_security_group" "allow_private" {
  name        = "allow_private"
  description = "Allow inbound traffic from private nodes"
  vpc_id      = "${module.vpc.vpc_id}"

  tags = {
    Name        = "Ingress and egress for load balancers."
    Description = "Security group for allowing external and internal networks to talk to load balancers."
  }

  ingress {
    description = "Allow any network to talk to load balancer via HTTP."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "Allow any network to talk to load balancer via HTTPS."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description     = "Allow private nodes access to inbound traffic."
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.private_workers.id}"]
  }

  ingress {
    description     = "Allow private nodes access to inbound traffic."
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.private_workers.id}"]
  }

  egress {
    description = "Allow nodes to egress to anywhere."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "workers" {
  name_prefix = "${terraform.workspace}"
  description = "Security group for all nodes in the cluster."
  vpc_id      = "${module.vpc.vpc_id}"
  tags        = "${map("Name", "${terraform.workspace}-eks_worker_sg", "kubernetes.io/cluster/${terraform.workspace}", "owned")}"
}

resource "aws_security_group_rule" "workers_egress_internet" {
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = "${aws_security_group.workers.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  description              = "Allow workers Kubelets and pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${module.eks-cluster.cluster_security_group_id}"
  from_port                = 1025
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${module.eks-cluster.cluster_security_group_id}"
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_dns_tcp" {
  description              = "Allow pods to talk to the cluster dns via tcp."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.workers.id}"
  from_port                = 53
  to_port                  = 53
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_dns_udp" {
  description              = "Allow pods to talk to the cluster dns via udp."
  protocol                 = "udp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.workers.id}"
  from_port                = 53
  to_port                  = 53
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_vault" {
  description              = "Allow pods to store and retrieve credentials from vault, limited by their own security roles"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.workers.id}"
  from_port                = 8200
  to_port                  = 8201
  type                     = "ingress"
}

resource "aws_security_group" "private_workers" {
  name_prefix = "${terraform.workspace}"
  description = "Security group for private nodes in the cluster."
  vpc_id      = "${module.vpc.vpc_id}"
  tags        = "${map("Name", "${terraform.workspace}-private-eks_worker_sg", "kubernetes.io/cluster/${terraform.workspace}-private", "owned")}"
}

resource "aws_security_group_rule" "private_workers_ingress_self" {
  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.private_workers.id}"
  source_security_group_id = "${aws_security_group.private_workers.id}"
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group" "public_workers" {
  name_prefix = "${terraform.workspace}"
  description = "Security group for public nodes in the cluster."
  vpc_id      = "${module.vpc.vpc_id}"
  tags        = "${map("Name", "${terraform.workspace}-public-eks_worker_sg", "kubernetes.io/cluster/${terraform.workspace}-public", "owned")}"
}

resource "aws_security_group_rule" "public_workers_ingress_self" {
  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.public_workers.id}"
  source_security_group_id = "${aws_security_group.public_workers.id}"
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

output "allow_all_security_group" {
  description = "Security group id to allow all traffic to access albs"
  value       = "${aws_security_group.allow_all.id}"
}

output "allow_private_security_group" {
  description = "Security group id to allow all traffic to access albs"
  value       = "${aws_security_group.allow_private.id}"
}

output "chatter_sg_id" {
  description = "The common security group for intra-VPC traffic"
  value       = "${aws_security_group.chatter.id}"
}
