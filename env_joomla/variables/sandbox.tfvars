environment = "sandbox"

vpc_id = "vpc-0b505c82e5aa08cb3"

public_subnet_ids = ["subnet-01c8230961c9598e3", "subnet-000a174a504a0208e", "subnet-0699fccb7c7dd91ef"]

private_subnet_ids = ["subnet-0dc37f26b358b1c41", "subnet-087a4bc429e7ee828", "subnet-0bee853043eba945b"]

credentials_profile = "sandbox"

vpc_name = "sandbox-dev"

vpc_single_nat_gateway = true

environment = "sandbox"

alm_account_id = "068920858268"

alm_workspace = "sandbox"

vpc_azs = ["us-east-2a", "us-east-2b", "us-east-2c"]

vpc_cidr = "10.100.0.0/16"

vpc_private_subnets = ["10.100.0.0/19", "10.100.64.0/19", "10.100.128.0/19"]

vpc_public_subnets = ["10.100.32.0/20", "10.100.96.0/20", "10.100.160.0/20"]

kubernetes_cluster_name = "sandbox-kube"

# Joomla
deployment_identifier = "sandbox"

db_instance_address = "joomla.cj574n7uvzxv.us-east-2.rds.amazonaws.com"

## Cluster variables
cluster_instance_ssh_public_key_path = "~/.ssh/id_rsa.pub"

cluster_instance_type = "t2.small"

cluster_instance_user_data_template = "templates/joomla_instance_userdata.sh.tpl"

cluster_instance_iam_policy_contents = "files/instance_policy.json"

cluster_minimum_size = 1

cluster_maximum_size = 1

cluster_desired_capacity = 1

allowed_cidrs = ["0.0.0.0/0"]

## Load Balancer variables
service_port = 80

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

memory = 512

directory_name = "joomla"

efs_encrypted = true
