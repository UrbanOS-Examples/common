data "aws_subnet" "az_selector" {
  id = "${local.cluster_subnet}"
}

resource "random_shuffle" "private_subnet" {
  input = ["${var.subnets}"]

  keepers = {
    private_subnets = "${join(",", var.subnets)}"
  }
}

resource "random_string" "ambari_admin_password" {
  length  = 40
  special = false
}

data "template_file" "cloudbreak_cluster" {
  template = "${file("${path.module}/templates/datalake-cluster-template.json.tpl")}"

  vars {
    BUCKET_CLOUD_STORAGE               = "${aws_s3_bucket.hadoop_cloud_storage.bucket}"
    INSTANCE_PROFILE_FOR_BUCKET_ACCESS = "${aws_iam_instance_profile.cloudstorage_bucket_access.arn}"
    CLUSTER_REGION                     = "${var.region}"
    CLUSTER_VPC                        = "${var.vpc_id}"
    CLUSTER_SUBNET                     = "${local.cluster_subnet}"
    CLUSTER_AZ                         = "${data.aws_subnet.az_selector.availability_zone}"

    MGMT_GROUP_INSTANCE_TYPE   = "${var.mgmt_group_instance_type}"
    MASTER_GROUP_INSTANCE_TYPE = "${var.master_group_instance_type}"
    BROKER_GROUP_INSTANCE_TYPE = "${var.broker_group_instance_type}"
    WORKER_GROUP_INSTANCE_TYPE = "${var.worker_group_instance_type}"
    MASTER_NODES_SG            = "${aws_security_group.datalake_master.id}"
    WORKER_NODES_SG            = "${aws_security_group.datalake_worker.id}"
    BROKER_NODE_COUNT          = "${var.broker_node_count}"
    WORKER_NODE_COUNT          = "${var.worker_node_count}"

    SSH_KEY               = "${var.ssh_key}"
    CREDENTIAL_NAME       = "${var.cloudbreak_credential_name}"
    HIVE_CONNECTION_NAME  = "${local.hive_db_name}"
    AMBARI_BLUEPRINT_NAME = "${local.ambari_blueprint_name}"
    AMBARI_GATEWAY_PATH   = "${local.ambari_gateway_path}"
    AMBARI_USERNAME       = "${local.ambari_username}"
    AMBARI_PASSWORD       = "${random_string.ambari_admin_password.result}"
  }
}

resource "null_resource" "cloudbreak_hive_db" {
  triggers {
    setup_updated    = "${sha1(file(local.ensure_hive_path))}"
    id_updated       = "${local.hive_db_name}"
    cloudbreak_ready = "${var.cloudbreak_ready}"
  }

  connection {
    type = "ssh"
    host = "${var.cloudbreak_ip}"
    user = "ec2-user"
  }

  provisioner "file" {
    source      = "${local.ensure_hive_path}"
    destination = "/tmp/ensure_hive_db.sh"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
bash /tmp/ensure_hive_db.sh \
  jdbc:postgresql://${aws_db_instance.hive_db.endpoint}/${aws_db_instance.hive_db.name} \
  ${local.hive_db_name} \
  ${aws_db_instance.hive_db.password}
EOF
      ,
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "cloudbreak_blueprint" {
  triggers {
    setup_updated    = "${sha1(file(local.ensure_blueprint_path))}"
    id_updated       = "${local.ambari_blueprint_name}"
    cloudbreak_ready = "${var.cloudbreak_ready}"
  }

  connection {
    type = "ssh"
    host = "${var.cloudbreak_ip}"
    user = "ec2-user"
  }

  provisioner "file" {
    source      = "${local.ambari_blueprint_path}"
    destination = "/tmp/blueprint.json"
  }

  provisioner "file" {
    source      = "${local.ensure_blueprint_path}"
    destination = "/tmp/ensure_blueprint.sh"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
bash /tmp/ensure_blueprint.sh \
  /tmp/blueprint.json \
  '${local.ambari_blueprint_name}'
EOF
      ,
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "cloudbreak_cluster" {
  triggers {
    setup_updated = "${sha1(file(local.ensure_cluster_path))}"
    cluster_name  = "${local.cluster_name}"                    // implies a change to the blueprint, etc.
  }

  depends_on = [
    "null_resource.cloudbreak_hive_db",
    "null_resource.cloudbreak_blueprint",
  ]

  connection {
    type = "ssh"
    host = "${var.cloudbreak_ip}"
    user = "ec2-user"
  }

  provisioner "file" {
    content     = "${data.template_file.cloudbreak_cluster.rendered}"
    destination = "/tmp/cluster.json"
  }

  provisioner "file" {
    source      = "${local.ensure_cluster_path}"
    destination = "/tmp/ensure_cluster.sh"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
bash /tmp/ensure_cluster.sh \
  /tmp/cluster.json \
  ${local.cluster_name}
EOF
      ,
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}
