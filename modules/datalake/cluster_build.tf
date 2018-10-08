data "template_file" "cloudbreak_cluster" {
  template = "${file("${path.module}/templates/datalake-cluster-template.json.tpl")}"

  vars {
    CLUSTER_REGION = "${var.region}"
    CLUSTER_VPC    = "${var.vpc_id}"
    CLUSTER_SUBNET = "${local.cluster_subnet}"
    CLUSTER_AZ     = "${data.aws_subnet.az_selector.availability_zone}"

    MGMT_GROUP_INSTANCE_TYPE   = "${var.mgmt_group_instance_type}"
    MASTER_GROUP_INSTANCE_TYPE = "${var.master_group_instance_type}"
    BROKER_GROUP_INSTANCE_TYPE = "${var.broker_group_instance_type}"
    WORKER_GROUP_INSTANCE_TYPE = "${var.worker_group_instance_type}"
    MASTER_NODES_SG            = "${aws_security_group.datalake_master.id}"
    WORKER_NODES_SG            = "${aws_security_group.datalake_worker.id}"
    BROKER_NODE_COUNT          = "${var.broker_node_count}"
    WORKER_NODE_COUNT          = "${var.worker_node_count}"

    SSH_KEY               = "${var.ssh_key}"
    CREDENTIAL_NAME       = "${local.cb_credential_name}"
    HIVE_CONNECTION_NAME  = "${local.hive_db_name}"
    AMBARI_BLUEPRINT_NAME = "${local.ambari_blueprint_name}"
    AMBARI_GATEWAY_PATH   = "${local.ambari_gateway_path}"
    AMBARI_USERNAME       = "${local.ambari_username}"
    AMBARI_PASSWORD       = "${random_string.cloudbreak_admin_password.result}"
  }
}

resource "null_resource" "cloudbreak_credential" {
  triggers {
    instance_updated = "${null_resource.cloudbreak.id}"
    setup_updated    = "${sha1(file(local.update_credentials_path))}"
    id_updated       = "${local.cb_credential_name}"
  }

  depends_on = [
    "aws_iam_role_policy.cloudbreak_credential",
  ]

  connection {
    type = "ssh"
    host = "${aws_instance.cloudbreak.private_ip}"
    user = "ec2-user"
  }

  provisioner "file" {
    source      = "${local.update_credentials_path}"
    destination = "/tmp/update_credentials.sh"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
bash /tmp/update_credentials.sh \
  ${local.cb_credential_name} \
  ${aws_iam_role.cloudbreak_credential.arn}
EOF
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "cloudbreak_hive_db" {
  triggers {
    instance_updated = "${null_resource.cloudbreak.id}"
    setup_updated    = "${sha1(file(local.update_hive_path))}"
    id_updated       = "${local.hive_db_name}"
  }

  connection {
    type = "ssh"
    host = "${aws_instance.cloudbreak.private_ip}"
    user = "ec2-user"
  }

  provisioner "file" {
    source      = "${local.update_hive_path}"
    destination = "/tmp/update_hive_db.sh"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
bash /tmp/update_hive_db.sh \
  jdbc:postgresql://${aws_db_instance.hive_db.endpoint}/${aws_db_instance.hive_db.name} \
  ${local.hive_db_name} \
  ${aws_db_instance.hive_db.password}
EOF
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "cloudbreak_blueprint" {
  triggers {
    instance_updated = "${null_resource.cloudbreak.id}"
    setup_updated    = "${sha1(file(local.update_blueprint_path))}"
    id_updated       = "${local.ambari_blueprint_name}"
  }

  connection {
    type = "ssh"
    host = "${aws_instance.cloudbreak.private_ip}"
    user = "ec2-user"
  }

  provisioner "file" {
    source      = "${local.ambari_blueprint_path}"
    destination = "/tmp/blueprint.json"
  }

  provisioner "file" {
    source      = "${local.update_blueprint_path}"
    destination = "/tmp/update_blueprint.sh"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
bash /tmp/update_blueprint.sh \
  /tmp/blueprint.json \
  '${local.ambari_blueprint_name}'
EOF
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "cloudbreak_cluster" {
  triggers {
    instance_updated = "${aws_instance.cloudbreak.id}"
    setup_updated    = "${sha1(file(local.update_cluster_path))}"
    id_updated       = "${local.cluster_name}"                    // implies a change to the blueprint, etc.
  }

  depends_on = [
    "null_resource.cloudbreak_credential",
    "null_resource.cloudbreak_hive_db",
    "null_resource.cloudbreak_blueprint",
  ]

  connection {
    type = "ssh"
    host = "${aws_instance.cloudbreak.private_ip}"
    user = "ec2-user"
  }

  provisioner "file" {
    content     = "${data.template_file.cloudbreak_cluster.rendered}"
    destination = "/tmp/cluster.json"
  }

  provisioner "file" {
    source      = "${local.update_cluster_path}"
    destination = "/tmp/update_cluster.sh"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
bash /tmp/update_cluster.sh \
  /tmp/cluster.json \
  ${local.cluster_name}
EOF
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}
