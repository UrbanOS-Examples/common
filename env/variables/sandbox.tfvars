# the enabled_features variable is interpreted by `tf-init` to enable different features by copying them
#   into the root working directory
# if you change the list of enabled features, or if you switch to a different environment
# whose list of enabled_features is different, you must re-run `tf-init` before any other terraform commands.
enabled_features = ["cloudbreak", "hive"]

credentials_profile = "sandbox"

accepter_credentials_profile = "sandbox"

root_dns_zone = "sandbox.internal.smartcolumbusos.com"

alm_account_id = "068920858268"

alm_state_bucket_name = "scos-sandbox-terraform-state"

role_arn = "arn:aws:iam::068920858268:role/admin_role"

alm_role_arn = "arn:aws:iam::068920858268:role/admin_role"

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRAvH6k7iEeRDz9SQtkH1o8KiUaed/e2hmzTUjA8bhmeWVLPsgCMKIUKR0jdPlvdZ0AmMLXswobsXj08dPgWxUZxoAWIqKCjd969KckydUpBtcb+X2Q+tpOcugBOQSY1H8hgNrdcRKEaUllTfvseJ9pBOYU7j9VuZ608HQhfZw7+aS8wi9o/BJwejtpWdlo6gkxXoIRqDX/ioYg+W6Tc7yoUzAEANwZAy3/3GKWDrh+9jnzR6mEEN48Nuee49wWfP5G0T/v4+Gvux5zioHb3rcmmR9YTkFOiv1poInhXlPdc7Q38yj+z6E+hACNN3rK80YjU0ByaSPltPjqm9ZYmPX"

# Joomla
joomla_instance_type = "t2.small"

joomla_backup_file_name = "site-www.smartcolumbusos.com-20180829-200003edt.zip"

joomla_backup_ami = "ami-09f6adc22771a71fa"

joomla_instance_ebs_optimized = false

# CKAN internal
ckan_internal_instance_type = "t2.small"

ckan_internal_backup_ami = "ami-0d34a796e1323e492"

ckan_internal_instance_ebs_optimized = false

# CKAN external
ckan_external_instance_type = "t2.small"

ckan_external_backup_ami = "ami-0d02a518404951549"

ckan_external_instance_ebs_optimized = false

# CKAN database
ckan_db_instance_class = "db.t2.large"

# ckan_db_allocated_storage = 30

ckan_db_snapshot_id = "arn:aws:rds:us-west-2:073132350570:snapshot:ckan-2018-09-24-12-10"

ckan_db_storage_encrypted = false

# Kong

kong_backup_ami = "ami-0acc9642a39710355"

kong_instance_ebs_optimized = false

# Kong database
kong_db_instance_class = "db.t2.2xlarge"

kong_db_snapshot_id = "arn:aws:rds:us-west-2:374013108165:snapshot:prod-kong-0-13-1-2018-08-29-07-20"

cloudbreak_db_multi_az = false
ambari_db_multi_az = false
hive_db_multi_az = false

cloudbreak_db_apply_immediately = true
ambari_db_apply_immediately = true
hive_db_apply_immediately = true
