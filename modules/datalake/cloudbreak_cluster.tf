data "template_file" "cb_instance_management" {
  template = "${file("${path.module}/templates/cloudbreak-instance-template.json")}"

  vars {
    COUNT          = 1
    GROUP          = "management"
    TYPE           = "GATEWAY"
    INSTANCE_TYPE  = "${var.mgmt_group_instance_type}"
    SECURITY_GROUP = "${aws_security_group.datalake_master.id}"
  }
}

data "template_file" "cb_instance_master_namenode1" {
  template = "${file("${path.module}/templates/cloudbreak-instance-template.json")}"

  vars {
    COUNT          = 1
    GROUP          = "master_namenode1"
    TYPE           = "CORE"
    INSTANCE_TYPE  = "${var.master_group_instance_type}"
    SECURITY_GROUP = "${aws_security_group.datalake_master.id}"
  }
}

data "template_file" "cb_instance_master_namenode2" {
  template = "${file("${path.module}/templates/cloudbreak-instance-template.json")}"

  vars {
    COUNT          = 1
    GROUP          = "master_namenode2"
    TYPE           = "CORE"
    INSTANCE_TYPE  = "${var.master_group_instance_type}"
    SECURITY_GROUP = "${aws_security_group.datalake_master.id}"
  }
}

data "template_file" "cb_instance_broker" {
  template = "${file("${path.module}/templates/cloudbreak-instance-template.json")}"

  vars {
    COUNT          = "${var.broker_node_count}"
    GROUP          = "broker"
    TYPE           = "CORE"
    INSTANCE_TYPE  = "${var.broker_group_instance_type}"
    SECURITY_GROUP = "${aws_security_group.datalake_worker.id}"
  }
}

data "template_file" "cb_instance_worker" {
  template = "${file("${path.module}/templates/cloudbreak-instance-template.json")}"

  vars {
    COUNT          = "${var.worker_node_count}"
    GROUP          = "worker"
    TYPE           = "CORE"
    INSTANCE_TYPE  = "${var.worker_group_instance_type}"
    SECURITY_GROUP = "${aws_security_group.datalake_worker.id}"
  }
}

locals {
  instance_groups = [
    "${data.template_file.cb_instance_management.rendered}",
    "${data.template_file.cb_instance_master_namenode1.rendered}",
    "${data.template_file.cb_instance_master_namenode2.rendered}",
    "${data.template_file.cb_instance_broker.rendered}",
    "${data.template_file.cb_instance_worker.rendered}"
  ]
}

data "template_file" "cloudbreak_cluster" {
  template = "${file("${path.module}/templates/datalake-cluster-template.json.tpl")}"

  #if you add a new variable here, you probably need to add a new keeper to random_pet.hadoop
  vars {
    HDP_CLUSTER_NAME                   = "${random_pet.hadoop.id}"
    CLOUD_STORAGE_BUCKET               = "${aws_s3_bucket.hadoop_cloud_storage.bucket}"
    INSTANCE_PROFILE_FOR_BUCKET_ACCESS = "${aws_iam_instance_profile.cloudstorage_bucket_access.arn}"
    CLUSTER_REGION                     = "${var.region}"
    CLUSTER_VPC                        = "${var.vpc_id}"
    CLUSTER_SUBNET                     = "${local.cluster_subnet}"
    CLUSTER_AZ                         = "${data.aws_subnet.az_selector.availability_zone}"

    INSTANCE_GROUPS = "${join(",", local.instance_groups)}"

    SSH_KEY                = "${var.ssh_key}"
    CREDENTIAL_NAME        = "${var.cloudbreak_credential_name}"
    HIVE_CONNECTION_NAME   = "${local.hive_db_name}"
    RANGER_CONNECTION_NAME = "${local.ranger_db_name}"
    LDAP_CONNECTION_NAME   = "${local.ldap_connection_name}"
    AMBARI_BLUEPRINT_NAME  = "${local.ambari_blueprint_name}"
    AMBARI_GATEWAY_PATH    = "${local.ambari_gateway_path}"
    AMBARI_USERNAME        = "${local.ambari_username}"
    AMBARI_PASSWORD        = "${random_string.ambari_admin_password.result}"
  }
}

resource "random_pet" "hadoop" {
  prefix = "hdp"
  keepers = {
    CLOUD_STORAGE_BUCKET               = "${aws_s3_bucket.hadoop_cloud_storage.bucket}"
    INSTANCE_PROFILE_FOR_BUCKET_ACCESS = "${aws_iam_instance_profile.cloudstorage_bucket_access.arn}"
    CLUSTER_REGION                     = "${var.region}"
    CLUSTER_VPC                        = "${var.vpc_id}"
    CLUSTER_SUBNET                     = "${local.cluster_subnet}"
    CLUSTER_AZ                         = "${data.aws_subnet.az_selector.availability_zone}"

    INSTANCE_GROUPS = "${join(",", local.instance_groups)}"

    SSH_KEY                = "${var.ssh_key}"
    CREDENTIAL_NAME        = "${var.cloudbreak_credential_name}"
    HIVE_CONNECTION_NAME   = "${local.hive_db_name}"
    RANGER_CONNECTION_NAME = "${local.ranger_db_name}"
    LDAP_CONNECTION_NAME   = "${local.ldap_connection_name}"
    AMBARI_BLUEPRINT_NAME  = "${local.ambari_blueprint_name}"
    AMBARI_GATEWAY_PATH    = "${local.ambari_gateway_path}"
    AMBARI_USERNAME        = "${local.ambari_username}"
    AMBARI_PASSWORD        = "${random_string.ambari_admin_password.result}"
  }
}

resource "null_resource" "cloudbreak_ldap_connection" {
  triggers {
    setup_updated    = "${sha1(file(local.ensure_ldap_path))}"
    id_updated       = "${local.ldap_connection_name}"
    cloudbreak_ready = "${var.cloudbreak_ready}"
  }

  connection {
    type = "ssh"
    host = "${var.cloudbreak_ip}"
    user = "ec2-user"
  }

  provisioner "file" {
    source      = "${local.ensure_ldap_path}"
    destination = "/tmp/ensure_ldap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
bash /tmp/ensure_ldap.sh \
  ${local.ldap_connection_name} \
  ${var.ldap_server} \
  ${var.ldap_port} \
  ${var.ldap_domain} \
  ${var.ldap_bind_user} \
  ${var.ldap_bind_password} \
  ${var.ldap_admin_group}
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
