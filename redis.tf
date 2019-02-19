resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis-cluster"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.0"
  port                 = 6379
  subnet_group_name    = "${aws_elasticache_subnet_group.redis_cache_subnet.name}"
  security_group_ids   = ["${aws_security_group.redis.id}"]
}

resource "aws_security_group" "redis" {
  name        = "redis"
  description = "Security group for all nodes in the cluster to be able to communicate with redis"
  vpc_id      = "${module.vpc.vpc_id}"

  tags = {
    Name = "redis"
  }
}

resource "aws_security_group_rule" "eks_workers_to_redis" {
  description              = "Allow worker nodes to communicate with redis"
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.redis.id}"
  source_security_group_id = "${aws_security_group.chatter.id}"
  from_port                = 6379
  to_port                  = 6379
  type                     = "ingress"
}

resource "aws_elasticache_subnet_group" "redis_cache_subnet" {
  name       = "redis-cache-subnet"
  subnet_ids = ["${module.vpc.private_subnets}"]
}

output "redis_hostname" {
  description = "Hostname for redis cluster"
  value       = "${lookup(aws_elasticache_cluster.redis.cache_nodes[0], "address")}"
}