aws_role_arn = "arn:aws:iam::073132350570:role/jenkins_role"

bastion_host_ip = "35.170.88.146"

joomla_old_ip = "172.16.5.114"

joomla_backup_ami = "ami-7a342205"

joomla_backup_file_name = "site-www.smartcolumbusos.com-20180722-200002edt.zip"

joomla_db_identifier = "dev-joomla"

joomla_instance_ebs_optimized = false

joomla_instance_profile = ""

joomla_instance_type = "t2.small"

joomla_keypair_name = "scos_joomla_dev"

scos_servers_sg_description = "SCOS Servers"

vpc_name = "DEV VPC"

vpc_regions = ["us-east-1a", "us-east-1b", "us-east-1f"]

ckan_internal_instance_type = "t2.small"

ckan_internal_backup_ami = "ami-5c302623"

ckan_keypair_name = "IDE_DEV_Key_Pair"

ckan_internal_instance_ebs_optimized = false

ckan_internal_instance_profile = ""

ckan_db_instance_class = "db.t2.large"

ckan_db_engine_version = "9.5.10"

ckan_db_parameter_group_name = "default.postgres9.5"

ckan_db_allocated_storage = 100

ckan_db_identifier = "dev-ckan"

ckan_rds_snapshot_id = "rds:dev-postgresql-instance-2018-07-30-07-39"

load_balancer_internal = true

ckan_external_ami = "ami-103d2b6f"

ckan_external_instance_type = "t2.small"

ckan_external_instance_ebs_optimized = false

ckan_external_instance_profile = ""

ckan_external_instance_class = "db.t2.large"

kong_db_identifier = "dev-kong"

kong_db_instance_class = "db.t2.large"

kong_ami = "ami-9b3f29e4"

kong_instance_profile = ""

kong_keypair_name = "Dev_Kong_Key_Pair"

kong_instance_type = "t2.small"

kong_rds_snapshot_id = "rds:dev-kong-0-13-1-2018-07-30-03-58"

rds_multi_az = false

kong_engine_version = "9.6.6"

kong_db_parameter_group_name = "default.postgres9.6"

kong_allocated_storage = 25

kong_instance_ebs_optimized = false

alb_external = false

target_group_prefix = "DEV"

ckan_db_storage_encrypted = false

alm_workspace = "alm"

alm_role_arn = "arn:aws:iam::199837183662:role/jenkins_role"

alm_state_bucket_name = "scos-alm-terraform-state"

public_dns_zone_id = "Z25PZI6XYQF2OB"
