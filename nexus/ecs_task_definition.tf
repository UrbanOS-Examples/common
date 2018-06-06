data "template_file" "task_definition" {
  template = "${file("${path.module}/templates/task-definition.json.tpl")}"

  vars {
    name = "${var.service_name}"
    image = "${var.service_image}"
    cpu = "${var.cpu}"
    memory = "${var.memory}"
    memoryReservation = "${var.memory_reservation}"
    command = "${jsonencode(var.service_command)}"
    port = "${var.service_port}"
    region = "${var.region}"
    log_group = "${module.service.log_group}"
    directory_name="${var.directory_name}"

  }
}
