credentials_profile = "sandbox"

accepter_credentials_profile = "sandbox"

root_dns_zone = "sandbox.internal.smartcolumbusos.com"

alm_account_id = "068920858268"

alm_state_bucket_name = "scos-sandbox-terraform-state"

role_arn = "arn:aws:iam::068920858268:role/admin_role"

alm_role_arn = "arn:aws:iam::068920858268:role/admin_role"

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZUiqcbO+5rkKXuYxBcUGtyLWtNainCjKaKaV4ZBEDhUZIxSJXLNq0SH7NxcODYDNNREqUdy6okJMP16NLuMHngmZYGW7FWaB5AVeKpYOdUHL2ik+RH0pY6PquGNWXMqUP+uVB8Kn5SgqsYT/u84Re6m0FztqVf7N8L5SuDbdnkvfLUc+R3JiMArvVGGKj5GkcUAqMFuzEuBQ2e7ID/bSevtMKfrPlOCLVSUzbMIVPCrxE7YyhTDgZjN7kMNZePWQhdyq86QzHJr50qa0fMnp2oUP1qwzbFjymYbG+oXPcj9dSiB7q2anf2imBnWP8JlhSinzJZrR2wa7Vn535MBhD"

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

ckan_db_allocated_storage = 30

ckan_db_snapshot_id = "arn:aws:rds:us-west-2:068920858268:snapshot:ckan-92b73cc8e5540bee9c9fb11fe9cd988e3d9b6f24"

ckan_db_storage_encrypted = false

# Kong

kong_backup_ami = "ami-0acc9642a39710355"

kong_instance_ebs_optimized = false

# Kong database
kong_db_instance_class = "db.t2.2xlarge"

kong_db_snapshot_id = "arn:aws:rds:us-west-2:374013108165:snapshot:prod-kong-0-13-1-2018-08-29-07-20"

# Cloudwatch monitoring
slack_path = "/services/T7LRETX4G/BA0EW8W6R/vRbX198LKBkhAEK64OnHCUXH"
slack_channel_name = "#pre_prod_alerts"