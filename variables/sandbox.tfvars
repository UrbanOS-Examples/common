# the enabled_features variable is interpreted by `tf-init` to enable different features by copying them
#   into the root working directory
# if you change the list of enabled features, or if you switch to a different environment
# whose list of enabled_features is different, you must re-run `tf-init` before any other terraform commands.
enabled_features = [
    "eks-cluster",
    "redis",
]

alm_account_id = "068920858268"

alm_state_bucket_name = "scos-sandbox-terraform-state"

role_arn = "arn:aws:iam::068920858268:role/admin_role"

alm_role_arn = "arn:aws:iam::068920858268:role/admin_role"

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRAvH6k7iEeRDz9SQtkH1o8KiUaed/e2hmzTUjA8bhmeWVLPsgCMKIUKR0jdPlvdZ0AmMLXswobsXj08dPgWxUZxoAWIqKCjd969KckydUpBtcb+X2Q+tpOcugBOQSY1H8hgNrdcRKEaUllTfvseJ9pBOYU7j9VuZ608HQhfZw7+aS8wi9o/BJwejtpWdlo6gkxXoIRqDX/ioYg+W6Tc7yoUzAEANwZAy3/3GKWDrh+9jnzR6mEEN48Nuee49wWfP5G0T/v4+Gvux5zioHb3rcmmR9YTkFOiv1poInhXlPdc7Q38yj+z6E+hACNN3rK80YjU0ByaSPltPjqm9ZYmPX"

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

#EKS Version
cluster_version = "1.11"

#EKS Workers
min_num_of_workers = 1
k8s_instance_size = "t3.medium"

#Jupyterhub EKS Workers
min_num_of_jupyterhub_workers=0
max_num_of_jupyterhub_workers=2

#Kafka EKS Workers
min_num_of_kafka_workers=1
max_num_of_kafka_workers=3

# LDAP datalake settings
ldap_server = "iam-master.alm.sandbox.internal.smartcolumbusos.com"
ldap_domain = "dc=sandbox,dc=internal,dc=smartcolumbusos,dc=com"

skip_final_db_snapshot = true

# Redis Elasticache settings
redis_node_type = "cache.t2.medium"

# Lime DB override settings
lime_db_size = "db.t2.small"
lime_db_storage = 20
lime_db_multi_az = false
lime_db_apply_immediately = true

recovery_window_in_days = 0

#DNS
is_public_facing = false

internal_root_dns_zone = "sandbox.internal.smartcolumbusos.com"

root_dns_zone = "sandbox-smartos.com"

is_sandbox = true # Leave this true

# Kerberos
kdc_instance_type = "t2.small"

kdc_domain = "OS-KDC.COM"
