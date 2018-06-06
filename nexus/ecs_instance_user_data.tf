data "template_file" "instance_user_data" {
  template = "${file("${path.module}/templates/instance-user-data.sh")}"

  vars {
    cluster_name = "${module.cluster.cluster_name}"
    mount_point = "/efs"
    directory_name="${var.directory_name}"
    efs_file_system_dns_name = "${data.terraform_remote_state.efs.dns_name}"
    efs_file_system_id = "${data.terraform_remote_state.efs.efs_id}"
    docker_image = "${var.service_image}"
  }
}
