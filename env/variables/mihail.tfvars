credentials_profile = "sandbox"

accepter_credentials_profile = "sandbox"

vpc_name = "mihail-dev"

vpc_single_nat_gateway = true

environment = "mihail"

private_dns_zone_name = "mihail.smartcolumbus.com"

alm_account_id = "068920858268"

alm_workspace = "sandbox"

vpc_cidr = "10.200.0.0/16"

vpc_private_subnets = ["10.200.0.0/19"]

vpc_public_subnets = ["10.200.32.0/20"]

kubernetes_cluster_name = "sandbox-kube"

# Joomla
deployment_identifier = "sandbox"

## Cluster variables
cluster_instance_ssh_public_key_path = "~/.ssh/id_rsa.pub"

cluster_instance_type = "t2.small"

cluster_instance_user_data_template = "templates/joomla_instance_userdata.sh.tpl"

cluster_instance_iam_policy_contents = "files/instance_policy.json"

cluster_minimum_size = 1

cluster_maximum_size = 3

cluster_desired_capacity = 2

allowed_cidrs = ["0.0.0.0/0"]

## Load Balancer variables
service_port = 8080

domain_name = "joomla.smartcolumbusos.com"

public_zone_id = ""

private_zone_id = ""

allow_lb_cidrs = ["0.0.0.0/0"]

include_public_dns_record = "no"

include_private_dns_record = "no"

expose_to_public_internet = "no"


## Service variables
service_image = "joomla"

service_task_container_definitions = "templates/task_definition.json.tpl"

attach_to_load_balancer = "yes"

memory = 1024

directory_name = "joomla"

efs_encrypted = true
