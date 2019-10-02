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

# Redis Elasticache settings
redis_node_type = "cache.t2.medium"

#DNS
internal_root_dns_zone = "sandbox.internal.smartcolumbusos.com"
root_dns_zone = "sandbox-smartos.com"
is_sandbox = true # Leave this true