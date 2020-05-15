variable "elasticsearch_instance_type" {
  description = "The size of the Elastic Search instances"
  default     = "t2.small.elasticsearch"
}

variable "elasticsearch_instance_count" {
  description = "The number of the ElasticSearch instances in the cluster"
  default     = 2
}

variable "elasticsearch_dedicated_master_enabled" {
  description = "Whether or not dedicated master nodes are enabled"
  default     = true
}

variable "elasticsearch_dedicated_master_type" {
  description = "The size of the ElasticSearch master instances (if enabled)"
  default     = "t2.small.elasticsearch"
}

variable "elasticsearch_dedicated_master_count" {
  description = "The number of the ElasticSearch master instances (if enabled) in the cluster"
  default     = 2
}

variable "elasticsearch_zone_awareness_enabled" {
  description = "Whether or not the cluster is zone aware"
  default     = true
}

variable "elasticsearch_version" {
  description = "The version of the ElasticSearch software to use"
  default     = "7.4"
}

variable "elasticsearch_node_to_node_encryption_enabled" {
  description = "Whether or not to enable node to node encryption for the ElasticSearch cluster"
  default     = true
}

variable "elasticsearch_at_rest_encryption_enabled" {
  description = "Whether or not to enable encryption at rest for the ElasticSearch cluster. NOT available for certain instance types"
  default     = false
}

variable "elasticsearch_ebs_volume_size" {
  description = "The size (in GB) of the EBS volume that backs ElasticSearch"
  default     = 10
}

resource "aws_elasticsearch_domain" "elasticsearch" {
  domain_name           = "elasticsearch-${terraform.workspace}"
  elasticsearch_version = "${var.elasticsearch_version}"

  cluster_config {
    instance_type            = "${var.elasticsearch_instance_type}"
    instance_count           = "${var.elasticsearch_instance_count}"
    dedicated_master_enabled = "${var.elasticsearch_dedicated_master_enabled}"
    dedicated_master_type    = "${var.elasticsearch_dedicated_master_type}"
    dedicated_master_count   = "${var.elasticsearch_dedicated_master_count}"

    zone_awareness_enabled = "${var.elasticsearch_zone_awareness_enabled}"

    zone_awareness_config {
      availability_zone_count = "${var.elasticsearch_instance_count}"
    }
  }

  encrypt_at_rest {
    enabled = "${var.elasticsearch_at_rest_encryption_enabled}"
  }

  node_to_node_encryption {
    enabled = "${var.elasticsearch_node_to_node_encryption_enabled}"
  }

  domain_endpoint_options {
    enforce_https = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = "${var.elasticsearch_ebs_volume_size}"
  }

  snapshot_options {
    automated_snapshot_start_hour = 5
  }

  vpc_options {
    # there are 6 total private subnets and this one includes only the main 3
    subnet_ids = ["${slice(local.private_subnets, 0, var.elasticsearch_instance_count)}"]

    security_group_ids = ["${aws_security_group.elasticsearch.id}"]
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": "es:*",
        "Resource": "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/elasticsearch-${terraform.workspace}/*"
      }
    ]
  }
  POLICY

  tags = {
    Domain = "elasticsearch-${terraform.workspace}"
  }

  depends_on = [
    "aws_iam_service_linked_role.elasticsearch"
  ]
}

resource "aws_iam_service_linked_role" "elasticsearch" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_security_group" "elasticsearch" {
  name        = "elasticsearch-${terraform.workspace}"
  description = "Security group for all instances in the ElasticSearch cluster."
  vpc_id      = "${module.vpc.vpc_id}"

  tags = {
    Name = "elasticsearch"
  }
}

resource "aws_security_group_rule" "eks_workers_to_elasticsearch" {
  description              = "Allow EKS worker nodes to communicate with ElasticSearch instances."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.elasticsearch.id}"
  source_security_group_id = "${aws_security_group.chatter.id}"
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "vpn_to_elasticsearch" {
  description       = "Allow VPN hosts to communicate with ElasticSearch instances."
  protocol          = "tcp"
  security_group_id = "${aws_security_group.elasticsearch.id}"
  cidr_blocks       = ["${data.terraform_remote_state.alm_remote_state.vpc_cidr_block}"]
  from_port         = 443
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "elasticsearch_intra_cluster" {
  description              = "Allow ElasticSearch cluster instances to talk to each other."
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.elasticsearch.id}"
  source_security_group_id = "${aws_security_group.elasticsearch.id}"
  from_port                = 0
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "elasticsearch_egress" {
  description       = "Allow ElasticSearch cluster to egress to anywhere."
  protocol          = "-1"
  security_group_id = "${aws_security_group.elasticsearch.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

output "elasticsearch_endpoint" {
  value       = "${aws_elasticsearch_domain.elasticsearch.endpoint}"
  description = "The ElasticSearch endpoint as a hostname"
}
