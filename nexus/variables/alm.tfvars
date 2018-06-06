# -------------- EFS ----------------
efs_encrypted = true
environment = "alm"
deployment_identifier = "alm"

#Cluster variables
cluster_name = "nexus-cluster"
cluster_instance_ssh_public_key_path = "~/.ssh/id_rsa.pub"
cluster_instance_type = "t2.large"
cluster_instance_user_data_template = "templates/instance-user-data.tpl"
cluster_instance_iam_policy_contents = "templates/instance-policy.json"

cluster_minimum_size = 1
cluster_maximum_size = 1
cluster_desired_capacity = 1
allowed_cidrs = ["0.0.0.0/0"]

#Load Balancer variables
service_port = 8081
domain_name = "deliveryPipeline.smartcolumbusos.com"
public_zone_id = "Z2TQLOWLDABB3W"
private_zone_id = "Z3KXSBDSLMD8L4"
allow_lb_cidrs = ["0.0.0.0/0"]
include_public_dns_record = "no"
include_private_dns_record = "no"
expose_to_public_internet = "yes"

#Service variables
service_name = "nexus"
service_image = "sonatype:nexus3"
service_task_container_definitions="templates/task-definition.json.tpl"
attach_to_load_balancer = "yes"
cpu = 256
memory = 2048
memory_reservation = 2048
directory_name = "nexus-data"
