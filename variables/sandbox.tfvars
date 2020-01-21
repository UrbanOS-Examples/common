# the enabled_features variable is interpreted by `tf-init` to enable different features by copying them
#   into the root working directory
# if you change the list of enabled features, or if you switch to a different environment
# whose list of enabled_features is different, you must re-run `tf-init` before any other terraform commands.
enabled_features = [
    "eks-cluster",
    "redis"
]

alm_account_id = "068920858268"

alm_state_bucket_name = "scos-sandbox-terraform-state"

role_arn = "arn:aws:iam::068920858268:role/admin_role"

alm_role_arn = "arn:aws:iam::068920858268:role/admin_role"

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCnatmW6UiFC9EIxmcdRebNnjFC6KfKJjNJhqCW8RwIqAfopSWITuCNsA6yRDauV1VJugmi8bZfb0ZDW+C/d6hAd2tpXjVURYVa43vQJezXWgAa3vHCyUVSwPNClXDx9hh7EqqhaYe/LyepTFaB9atcueesKbqH5O2F24sEDAz7lFYEouKPLk36kyORT11WD47EfGwEbGJFCIaRKutBlcY9YYzdi/306cKsHvX5wZacminBGlvOhfkZ/07F60ShP3floIFgkYAKttHjM4oirXpGpYxI4Yz5oaH9wDQfcNfFMQty/FyAQ0Yvy3Sr8xCouWNK7tKJdo/2vCQFvAy9zg9MGsZx+e7y7PNmkPasen6Uu/yzl3MCPp2hyBcjjP5Pnz7O6Qw97D6T7vLybpr5W9OHumAB1ZoW3cFX7kOFHlp1114u3D1QX55Y7rWpAz7F+ZWSsf5K3DtMwKdQ8RBhL3gUFhvLSbpdvH/01VM5+2h9xrgL2j4+6SDwNUFHgYraSMKdsQJFYa3J2rrbF0phqBIqp9aKPk5DLPkVqxfd7JkGEUlng9Sn8Pk7VvJqvjLsxta8yhMtv9dhr7CA8tr57oQ2YTEf5rErshmTSPU5JLDW5KpJcbII8C6bC9QEIydpd3VtXnu9+AsFbmHWFNtmkuv4y+BvZXG7XR0Eu6n5C/biKw== oasis2@MBP-6"

#EKS Version
cluster_version = "1.13"

#EKS Workers
min_num_of_workers = 1
k8s_instance_size = "t3.medium"

#Kafka EKS Workers
min_num_of_kafka_workers=1
max_num_of_kafka_workers=3

# Redis Elasticache settings
redis_node_type = "cache.t2.medium"

#DNS
internal_root_dns_zone = "sandbox.internal.smartcolumbusos.com"
root_dns_zone = "sandbox-smartos.com"
is_sandbox = true # Leave this true
