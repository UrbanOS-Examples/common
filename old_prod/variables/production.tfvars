aws_role_arn = "arn:aws:iam::073132350570:role/jenkins_role"

bastion_host_ip = "35.170.88.146"

joomla_old_ip = "172.16.5.114"

//joomla_backup_ami = ""

//joomla_backup_file_name = ""

joomla_db_identifier = "joomlaprod"

joomla_instance_ebs_optimized = true

joomla_instance_profile = ""

joomla_instance_type = "m4.2xlarge"

joomla_keypair_name = "Production_Joomla_Key_Pair"

scos_servers_sg_description = "SCOS Servers"

vpc_name = "Prod-VPC"

vpc_regions = ["us-east-1a", "us-east-1b", "us-east-1f"]

ckan_internal_instance_type = "m4.xlarge"

//ckan_internal_backup_ami = ""

ckan_keypair_name = "Production_CKAN_Key_Pair"

ckan_internal_instance_ebs_optimized = true

ckan_internal_instance_profile = ""

ckan_db_instance_class = "db.m4.large"

ckan_db_engine_version = "9.6.6"

ckan_db_parameter_group_name = "default.postgres9.6"

ckan_db_allocated_storage = 1000

ckan_db_identifier = "production-ckan"

//ckan_rds_snapshot_id = ""

//ckan_external_ami = ""

ckan_external_instance_type = "m4.xlarge"

ckan_external_instance_ebs_optimized = true

ckan_external_instance_profile = ""

kong_db_identifier = "prod-kong-0-13-1"

kong_db_instance_class = "db.m4.large"

//kong_ami = ""

kong_instance_profile = ""

kong_keypair_name = "Prod_Kong_Key_Pair"

kong_instance_type = "m4.large"

//kong_rds_snapshot_id = ""

rds_multi_az = true 

kong_engine_version = "9.6.6"

kong_db_parameter_group_name = "default.postgres9.6"

kong_allocated_storage = 100 

kong_instance_ebs_optimized = true 

alb_external = false

target_group_prefix = "prod"

ckan_db_storage_encrypted = true