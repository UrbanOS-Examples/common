provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
   bucket = "scos-sandbox-terraform-state"
   key    = "nexus"
   region = "us-east-2"
   dynamodb_table="terraform_lock"
   encrypt = "true"
 }
}

data "terraform_remote_state" "vpc" {
 backend     = "s3"
 workspace = "${terraform.workspace}"

 config {
   bucket = "scos-sandbox-terraform-state"
   key    = "alm"
   region = "us-east-2"
 }
}

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

data "template_file" "instance_user_data" {
  template = "${file("${path.module}/templates/instance-user-data.sh")}"

  vars {
    cluster_name = "${module.cluster.cluster_name}"
    mount_point = "/efs"
    directory_name="${var.directory_name}"
    efs_file_system_dns_name = "${module.efs.dns_name}"
    efs_file_system_id = "${module.efs.efs_id}"
    docker_image = "${var.service_image}"
  }
}


module "efs" {
  source = "../modules/efs"

  efs_name = "${var.efs_name}"
  efs_mode = "${var.efs_mode}"
  efs_encrypted = "${var.efs_encrypted}"
}

module "mount_targets" {
  source = "../modules/efs_mount_target"
  sg_name = "nexus-data"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  mount_target_tags  = {"name" = "nexus", "environment" = "${var.environment}"}
  subnet = "${data.terraform_remote_state.vpc.private_subnets[0]}"
  efs_id = "${module.efs.efs_id}"
}

module "cluster" {
  source = "infrablocks/ecs-cluster/aws"
  version = "0.2.5"

  region = "${var.region}"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  subnet_ids = "${join(",",data.terraform_remote_state.vpc.private_subnets)}"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  cluster_name = "${var.cluster_name}"
  cluster_instance_ssh_public_key_path =  "${var.cluster_instance_ssh_public_key_path}"
  cluster_instance_type =  "${var.cluster_instance_type}"
  cluster_instance_user_data_template =  "${data.template_file.instance_user_data.rendered}"
  cluster_instance_iam_policy_contents =  "${file(var.cluster_instance_iam_policy_contents)}"

  cluster_minimum_size =  "${var.cluster_minimum_size}"
  cluster_maximum_size =  "${var.cluster_maximum_size}"
  cluster_desired_capacity =  "${var.cluster_desired_capacity}"
  allowed_cidrs =  "${var.allowed_cidrs}"

}

module "ecs_load_balancer" {
  source = "github.com/SmartColumbusOS/terraform-aws-ecs-load-balancer"

  region = "${var.region}"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  subnet_ids = "${data.terraform_remote_state.vpc.public_subnets}"

  component =  "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  service_name = "${var.service_name}"
  service_port = "${var.service_port}"
  service_certificate_arn = ""

  domain_name = "${var.domain_name}"
  public_zone_id = "${var.public_zone_id}"
  private_zone_id = "${var.private_zone_id}"

  health_check_target = "HTTP:8081/"

  allow_cidrs = "${var.allow_lb_cidrs}"

  include_public_dns_record = "${var.include_public_dns_record}"
  include_private_dns_record = "${var.include_private_dns_record}"

  expose_to_public_internet = "${var.expose_to_public_internet}"
}

module "service" {
  source = "infrablocks/ecs-service/aws"
  version = "0.1.10"

  region = "${var.region}"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  service_name = "${var.service_name}"
  service_image = "${var.service_image}"
  service_port = "${var.service_port}"
  service_task_container_definitions="${data.template_file.task_definition.rendered}"

  service_desired_count = "1"
  service_deployment_maximum_percent = "100"
  service_deployment_minimum_healthy_percent = "50"

  attach_to_load_balancer = "${var.attach_to_load_balancer}"
  service_elb_name = "${module.ecs_load_balancer.name}"

  service_volumes = [
    {
      name = "${var.directory_name}"
      host_path = "/efs/nexus-data"
    }
  ]

  ecs_cluster_id = "${module.cluster.cluster_id}"
  ecs_cluster_service_role_arn = "${module.cluster.service_role_arn}"
}

#todo: scaling policy, consistent tags