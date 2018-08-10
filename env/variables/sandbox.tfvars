credentials_profile = "sandbox"

accepter_credentials_profile = "sandbox"

root_dns_zone = "sandbox.internal.smartcolumbusos.com"

alm_account_id = "068920858268"

alm_state_bucket_name = "scos-sandbox-terraform-state"

role_arn = "arn:aws:iam::068920858268:role/admin_role"

alm_role_arn = "arn:aws:iam::068920858268:role/admin_role"

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRAvH6k7iEeRDz9SQtkH1o8KiUaed/e2hmzTUjA8bhmeWVLPsgCMKIUKR0jdPlvdZ0AmMLXswobsXj08dPgWxUZxoAWIqKCjd969KckydUpBtcb+X2Q+tpOcugBOQSY1H8hgNrdcRKEaUllTfvseJ9pBOYU7j9VuZ608HQhfZw7+aS8wi9o/BJwejtpWdlo6gkxXoIRqDX/ioYg+W6Tc7yoUzAEANwZAy3/3GKWDrh+9jnzR6mEEN48Nuee49wWfP5G0T/v4+Gvux5zioHb3rcmmR9YTkFOiv1poInhXlPdc7Q38yj+z6E+hACNN3rK80YjU0ByaSPltPjqm9ZYmPX"

# Joomla
joomla_backup_file_name = "joomla_sandbox_initial.zip"

joomla_db_password = "topsecret"

joomla_backup_ami = "ami-0394364390eccca33"

# CKAN internal
ckan_internal_instance_type = "t2.small"

ckan_internal_backup_ami = "ami-07830280700c20ce4"

ckan_internal_instance_ebs_optimized = false

# CKAN external
ckan_external_instance_type = "t2.small"

ckan_external_ami = "ami-08e9478597d2717c6"

ckan_external_instance_ebs_optimized = false

# CKAN database
ckan_db_instance_class = "db.t2.large"

ckan_db_engine_version = "9.6.6"

ckan_db_parameter_group_name = "default.postgres9.6"

ckan_db_allocated_storage = 30

ckan_db_snapshot_id = "arn:aws:rds:us-west-2:068920858268:snapshot:ckan-2018-08-20"

ckan_db_storage_encrypted = false

# Kong
kong_db_identifier = "kong"

kong_db_instance_class = "db.t2.2xlarge"

kong_ami = "ami-0952f3608695de2cf"

kong_instance_profile = ""

kong_instance_type = "t2.small"

kong_rds_snapshot_id = "arn:aws:rds:us-west-2:068920858268:snapshot:kong-2018-08-20"

kong_db_parameter_group_name = "default.postgres9.6"

kong_allocated_storage = 100

kong_instance_ebs_optimized = false

kong_db_password = "SuperSecret"
