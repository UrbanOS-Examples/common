resource "aws_elasticache_cluster" "redis" {
  cluster_id               = "redis-${terraform.workspace}"
  engine                   = "redis"
  node_type                = "${var.redis_node_type}"
  num_cache_nodes          = 1
  parameter_group_name     = "default.redis5.0"
  engine_version           = "5.0.0"
  port                     = 6379
  subnet_group_name        = "${aws_elasticache_subnet_group.redis_cache_subnet.name}"
  security_group_ids       = ["${aws_security_group.redis.id}"]
  snapshot_retention_limit = 7
  snapshot_window          = "06:00-07:00"
  maintenance_window       = "sun:07:15-sun:09:00"
  apply_immediately        = true
}

resource "aws_security_group" "redis" {
  name        = "redis-${terraform.workspace}"
  description = "Security group for all nodes in the cluster to be able to communicate with redis"
  vpc_id      = "${module.vpc.vpc_id}"

  tags = {
    Name = "redis"
  }
}

resource "aws_security_group_rule" "eks_workers_to_redis" {
  description              = "Allow worker nodes to communicate with redis"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.redis.id}"
  source_security_group_id = "${aws_security_group.chatter.id}"
  from_port                = 6379
  to_port                  = 6379
  type                     = "ingress"
}

resource "aws_elasticache_subnet_group" "redis_cache_subnet" {
  name       = "redis-cache-subnet-${terraform.workspace}"
  subnet_ids = ["${module.vpc.private_subnets}"]
}

resource "null_resource" "redis_external_service" {
  depends_on = ["data.external.helm_file_change_check_redis", "null_resource.eks_infrastructure"]

  provisioner "local-exec" {
    command = <<EOF
set -e
export KUBECONFIG=${path.module}/kubeconfig_streaming-kube-${terraform.workspace}

helm upgrade --install common-external-services ${path.module}/helm/external-services \
    --namespace=external-services \
    --set redis.host="${lookup(aws_elasticache_cluster.redis.cache_nodes[0], "address")}"

EOF
  }

  triggers {
    helm_file_change_check = "${data.external.helm_file_change_check_redis.result.md5_result}"
    redis_host             = "${lookup(aws_elasticache_cluster.redis.cache_nodes[0], "address")}"
  }
}

data "external" "helm_file_change_check_redis" {
  program = [
    "${path.module}/files/scripts/helm_file_change_check.sh",
    "${path.module}/helm/external-services",
  ]
}

variable "redis_node_type" {
  description = "The size of the Redis Elasticache instance"
  default     = "cache.t2.medium"
}
