resource "random_string" "ambari_admin_password" {
  length  = 40
  special = false
}

resource "aws_secretsmanager_secret" "ambari_admin_password" {
  name = "${terraform.workspace}-ambari-admin-password"
  recovery_window_in_days = "${var.recovery_window_in_days}"
}

resource "aws_secretsmanager_secret_version" "ambari_admin_password" {
  secret_id     = "${aws_secretsmanager_secret.ambari_admin_password.id}"
  secret_string = "${random_string.ambari_admin_password.result}"
}

data "template_file" "cloudbreak_blueprint" {
  template = "${file("${path.module}/templates/datalake-ambari-blueprint.json.tpl")}"

  vars {
    CLOUD_STORAGE_BUCKET = "${aws_s3_bucket.hadoop_cloud_storage.bucket}"
    AMBARI_PASSWORD      = "${random_string.ambari_admin_password.result}"
    RANGER_DB_ENDPOINT   = "${aws_db_instance.ranger_db.endpoint}"
  }
}

resource "null_resource" "cloudbreak_blueprint" {
  triggers {
    setup_updated    = "${sha1(file(local.ensure_blueprint_path))}"
    id_updated       = "${local.ambari_blueprint_name}"
    cloudbreak_ready = "${var.cloudbreak_ready}"
  }

  depends_on = [
    "aws_s3_bucket.hadoop_cloud_storage"
  ]

  connection {
    type = "ssh"
    host = "${var.cloudbreak_ip}"
    user = "ec2-user"
  }

  provisioner "file" {
    content     = "${data.template_file.cloudbreak_blueprint.rendered}"
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
