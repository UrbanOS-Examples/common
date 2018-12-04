resource "aws_route53_zone" "public_hosted_zone" {
  name   =  "${local.cluster_name}.${var.parent_hosted_zone_name}"
  force_destroy = true
}

resource "aws_route53_record" "env_ns_record" {
  name = "${local.cluster_name}"
  zone_id = "${var.parent_hosted_zone_id}"
  type = "NS"
  ttl = 300
  records = ["${aws_route53_zone.public_hosted_zone.name_servers}"]
}

data "aws_instances" "cb_cluster_workers" {
  depends_on = ["null_resource.cloudbreak_cluster"]

  instance_tags = {
    CloudbreakClusterName = "${local.cluster_name}"
    instanceGroup         = "worker"
  }
}

resource "aws_route53_record" "cb_cluster_workers" {
  count = "${var.worker_node_count}"

  name    = "worker-${count.index}"
  zone_id = "${aws_route53_zone.public_hosted_zone.id}"
  type    = "A"
  ttl     = 300
  records = ["${element(data.aws_instances.cb_cluster_workers.private_ips, count.index)}"]
}

data "aws_instances" "cb_cluster_brokers" {
  depends_on = ["null_resource.cloudbreak_cluster"]

  instance_tags = {
    CloudbreakClusterName = "${local.cluster_name}"
    instanceGroup         = "broker"
  }
}

resource "aws_route53_record" "cb_cluster_brokers" {
  count = "${var.broker_node_count}"

  name    = "broker-${count.index}"
  zone_id = "${aws_route53_zone.public_hosted_zone.id}"
  type    = "A"
  ttl     = 300
  records = ["${element(data.aws_instances.cb_cluster_brokers.private_ips, count.index)}"]
}

data "aws_instance" "cb_cluster_master_namenode1" {
  depends_on = ["null_resource.cloudbreak_cluster"]

  instance_tags = {
    CloudbreakClusterName = "${local.cluster_name}"
    instanceGroup         = "master_namenode1"
  }
}

resource "aws_route53_record" "cb_cluster_master_namenode1" {
  name    = "master-namenode1"
  zone_id = "${aws_route53_zone.public_hosted_zone.id}"
  type    = "A"
  ttl     = 300
  records = ["${data.aws_instance.cb_cluster_master_namenode1.private_ip}"]
}

data "aws_instance" "cb_cluster_master_namenode2" {
  depends_on = ["null_resource.cloudbreak_cluster"]

  instance_tags = {
    CloudbreakClusterName = "${local.cluster_name}"
    instanceGroup         = "master_namenode2"
  }
}

resource "aws_route53_record" "cb_cluster_master_namenode2" {
  name    = "master-namenode2"
  zone_id = "${aws_route53_zone.public_hosted_zone.id}"
  type    = "A"
  ttl     = 300
  records = ["${data.aws_instance.cb_cluster_master_namenode2.private_ip}"]
}

data "aws_instance" "cb_cluster_management" {
  depends_on = ["null_resource.cloudbreak_cluster"]

  instance_tags = {
    CloudbreakClusterName = "${local.cluster_name}"
    instanceGroup         = "management"
  }
}

resource "aws_route53_record" "cb_cluster_management" {
  name    = "management"
  zone_id = "${aws_route53_zone.public_hosted_zone.id}"
  type    = "A"
  ttl     = 300
  records = ["${data.aws_instance.cb_cluster_management.private_ip}"]
}

resource "aws_route53_record" "datalake_dns" {
  zone_id = "${var.datalake_dns_zone_id}"
  name    = "datalake"
  type    = "A"

  alias {
    name                   = "${aws_alb.datalake.dns_name}"
    zone_id                = "${aws_alb.datalake.zone_id}"
    evaluate_target_health = false
  }
}

# TODO - simplify cluster to not be HA and just access these either through Knox or single, non round-robin records
resource "aws_route53_record" "datalake_hive_dns" {
  zone_id = "${var.datalake_dns_zone_id}"
  name    = "datalake-hive"
  type    = "A"
  ttl     = 300

  records = [
    "${data.aws_instance.cb_cluster_master_namenode1.private_ip}",
    "${data.aws_instance.cb_cluster_master_namenode2.private_ip}"
  ]
}

# as far as we know, hadoop cannot DNS round-robin or load balance a namenode
resource "aws_route53_record" "datalake_master-namenode1_dns" {
  zone_id = "${var.datalake_dns_zone_id}"
  name    = "datalake-master-namenode1"
  type    = "CNAME"
  ttl     = 300

  records = ["${aws_route53_record.cb_cluster_master_namenode1.fqdn}"]
}

resource "aws_route53_record" "datalake_master-namenode2_dns" {
  zone_id = "${var.datalake_dns_zone_id}"
  name    = "datalake-master-namenode2"
  type    = "CNAME"
  ttl     = 300

  records = ["${aws_route53_record.cb_cluster_master_namenode2.fqdn}"]
}
