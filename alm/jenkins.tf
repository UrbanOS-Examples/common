data "template_file" "instance_user_data" {
  template = "${file("templates/jenkins_instance_userdata.sh.tpl")}"

  vars {
    cluster_name             = "${module.jenkins_cluster.cluster_name}"
    mount_point              = "/efs"
    directory_name           = "${var.directory_name}"
    efs_file_system_dns_name = "${module.jenkins_efs.dns_name}"
    efs_file_system_id       = "${module.jenkins_efs.efs_id}"
    docker_image             = "${var.docker_registry}/${var.service_image}"
  }
}

data "template_file" "task_definition" {
  template = "${file("templates/task_definition.json.tpl")}"

  vars {
    name           = "${var.service_name}"
    image          = "${var.docker_registry}/${var.service_image}"
    memory         = "1024"
    command        = "${jsonencode(var.service_command)}"
    port           = "${var.service_port}"
    region         = "${var.region}"
    log_group      = "${module.jenkins_service.log_group}"
    elb_name       = "${module.jenkins_ecs_load_balancer.name}"
    directory_name = "${var.directory_name}"
  }
}

module "jenkins_efs" {
  source = "../modules/efs"

  efs_name      = "${var.efs_name}"
  efs_mode      = "${var.efs_mode}"
  efs_encrypted = true
}

module "jenkins_mount_targets" {
  source  = "../modules/efs_mount_target"
  sg_name = "jenkins-data"
  vpc_id  = "${module.vpc.vpc_id}"
  subnet  = "${module.vpc.private_subnets[0]}"
  efs_id  = "${module.jenkins_efs.efs_id}"

  mount_target_tags = {
    "name"        = "jenkins"
    "environment" = "${var.environment}"
  }
}

module "jenkins_cluster" {
  source  = "infrablocks/ecs-cluster/aws"
  version = "0.2.5"

  region     = "${var.region}"
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${join(",",module.vpc.private_subnets)}"

  component             = "${var.component}"
  deployment_identifier = "${var.environment}"

  cluster_name                         = "${terraform.workspace}_${var.cluster_name}"
  cluster_instance_ssh_public_key_path = "${var.cluster_instance_ssh_public_key_path}"
  cluster_instance_type                = "${var.cluster_instance_type}"
  cluster_instance_user_data_template  = "${data.template_file.instance_user_data.rendered}"
  cluster_instance_iam_policy_contents = "${file("files/instance_policy.json")}"

  cluster_minimum_size     = "${var.cluster_minimum_size}"
  cluster_maximum_size     = "${var.cluster_maximum_size}"
  cluster_desired_capacity = "${var.cluster_desired_capacity}"
  allowed_cidrs            = "${var.allowed_cidrs}"
}

module "jenkins_ecs_load_balancer" {
  source = "../modules/elb"

  region     = "${var.region}"
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.private_subnets}"

  component             = "${var.component}"
  deployment_identifier = "${var.environment}"

  service_name            = "${terraform.workspace}_${var.service_name}"
  service_port            = "${var.service_port}"
  service_certificate_arn = ""

  domain_name     = "${var.domain_name}"

  health_check_target = "HTTP:8080/login"

  allow_cidrs = "${var.allowed_cidrs}"

  include_public_dns_record  = "no"
  include_private_dns_record = "no"

  expose_to_public_internet = "no"
}

module "jenkins_service" {
  source  = "infrablocks/ecs-service/aws"
  version = "0.1.10"

  region = "${var.region}"
  vpc_id = "${module.vpc.vpc_id}"

  component             = "${var.component}"
  deployment_identifier = "${var.environment}"

  service_name                       = "${var.service_name}"
  service_image                      = "${var.docker_registry}/${var.service_image}"
  service_port                       = "${var.service_port}"
  service_task_container_definitions = "${data.template_file.task_definition.rendered}"

  service_desired_count                      = "1"
  service_deployment_maximum_percent         = "100"
  service_deployment_minimum_healthy_percent = "50"

  attach_to_load_balancer = "yes"
  service_elb_name        = "${module.jenkins_ecs_load_balancer.name}"

  service_volumes = [
    {
      name      = "${var.directory_name}"
      host_path = "/efs/${var.directory_name}"
    },
    {
      name      = "docker-socket"
      host_path = "/var/run/docker.sock"
    },
  ]

  ecs_cluster_id               = "${module.jenkins_cluster.cluster_id}"
  ecs_cluster_service_role_arn = "${module.jenkins_cluster.service_role_arn}"
}

variable "component" {
  description = "The component this cluster will contain"
  default     = "delivery-pipeline"
}

variable "docker_registry" {
  description = "The URL of the docker registry"
}

variable "cluster_name" {
  description = "AWS The name of the cluster to create"
  default     = "jenkins_cluster"
}

variable "cluster_instance_type" {
  description = "The instance type of the container instances"
  default     = "t2.medium"
}

variable "cluster_minimum_size" {
  description = "The minimum size of the ECS cluster"
  default     = 1
}

variable "cluster_maximum_size" {
  description = "The maximum size of the ECS cluster"
  default     = 10
}

variable "cluster_desired_capacity" {
  description = "The desired capacity of the ECS cluster"
  default     = 3
}

variable "domain_name" {
  description = "The domain name of the supplied Route 53 zones."
}

variable "service_port" {
  description = "The port on which the service containers are listening"
  default     = 8080
}

variable "service_name" {
  description = "The name of the service being created"
  default     = "jenkins_master"
}

variable "service_image" {
  description = "The docker image (including version) to deploy"
  default     = "scos/jenkins-master:latest"
}

variable "service_elb_name" {
  description = "The name of the ELB to configure to point at the service containers"
  default     = ""
}

variable "service_command" {
  description = "The command to run to start the container."
  type        = "list"
  default     = []
}

variable "directory_name" {
  description = "Directory where data is saved"
  default     = "jenkins_home"
}

variable "efs_name" {
  description = "EFS name"
  default     = "jenkins"
}

variable "efs_mode" {
  description = "xfer mode:  generalPurpose OR maxIO"
  default     = "generalPurpose"
}

variable "jenkins_relay_user_data_template" {
  description = "Location of the userdata template for the jenkins relay"
  default     = "templates/jenkins_relay_userdata.sh.tpl"
}

variable "jenkins_relay_docker_image" {
  description = "Docker image for the jenkins relay"
  default     = "scos/jenkins-relay:latest"
}

output "efs_id" {
  description = "The ID of the EFS"
  value       = "${module.jenkins_efs.efs_id}"
}

output "kms_key_id" {
  description = "The ARN for the KMS encryption key"
  value       = "${module.jenkins_efs.kms_key_id}"
}

output "dns_name" {
  description = "The DNS name for the filesystem"
  value       = "${module.jenkins_efs.dns_name}"
}