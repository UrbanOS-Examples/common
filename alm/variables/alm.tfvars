vpc_name = "alm"

vpc_single_nat_gateway = true

environment = "alm"

credentials_profile = "jenkins"

vpc_private_subnets = ["10.0.0.0/19", "10.0.64.0/19", "10.0.128.0/19"]

vpc_public_subnets = ["10.0.32.0/20", "10.0.96.0/20", "10.0.160.0/20"]

vpc_azs = ["us-east-2a", "us-east-2b", "us-east-2c"]

openvpn_admin_password_secret_arn = "arn:aws:secretsmanager:us-east-2:199837183662:secret:openvpn_admin_password-beMNOa"

# Jenkins
deployment_identifier = "alm"

## Cluster variables
cluster_instance_ssh_public_key_path = "~/.ssh/id_rsa.pub"

cluster_instance_type = "t2.small"

cluster_instance_user_data_template = "templates/jenkins_instance_userdata.sh.tpl"

cluster_instance_iam_policy_contents = "files/instance_policy.json"

cluster_minimum_size = 1

cluster_maximum_size = 3

cluster_desired_capacity = 2

allowed_cidrs = ["0.0.0.0/0"]

## Load Balancer variables
service_port = 8080

domain_name = "deliveryPipeline.smartcolumbusos.com"

public_zone_id = ""

private_zone_id = ""

allow_lb_cidrs = ["0.0.0.0/0"]

include_public_dns_record = "no"

include_private_dns_record = "no"

expose_to_public_internet = "no"

## Service variables
service_image = "199837183662.dkr.ecr.us-east-2.amazonaws.com/scos/jenkins-master:latest"

service_task_container_definitions = "templates/task_definition.json.tpl"

attach_to_load_balancer = "yes"

memory = 1024

directory_name = "jenkins_home"

efs_encrypted = true

# COTA Streaming data proxy
cota_ui_host = "internal-a4244d43570cc11e8a71c02598f28489-1213344449.us-east-2.elb.amazonaws.com"

streaming_consumer_host = "internal-a165a2ee470cc11e8a71c02598f28489-494078599.us-east-2.elb.amazonaws.com"

alm_account_id = "199837183662"