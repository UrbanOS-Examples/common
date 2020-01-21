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

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/j2hw/hzmjWcaWolUW0PLhFDdDEDr6T4Q2Fc0ZC6AgX3RMlwXOmsfnI/YEFTLUSqt2s9VbsqHrdJnRbD/r+dsVdLrxe71ukQi7MqbiLDMyWzKV5w1QUd1NFk+8IvtWB2+geudfazXV3AZy3JaKjY+fqZcoWLsCfnYYwdeYUxjX0eAFgwxlk8pz4/7LC443cVviJlmv3f82LjB8Gg6I1t+sM19aRiB9YjErZYwdwAd6NsYvNrcVFZLGXxhFCgld+6+V4H5qHMijSOzbQObZSWbzJvZw7/xBn7gk+myqoauYujeGoiUtf7Mum9GVQVG/3G2C1e2LD3d9roKfD+SGSANBLeEjaS+qvyazknIuXRr1aiJ1HXdk1JGnqDsaQh161F+Wm+P5o3/wiPyEdFTtS/KPgoDtVWm8e5VOe01RGSxFV2F0sdsRTR07SA1OoH1t5icG6AhXd5hxL9yhSckiRzNaIt0EWR5XU1TMYz8aDiR8oXNqMq96uKT7C3Y1y/fNGOYCSWK94iRXsQ/JkOhjulXAGQfFHF5zJMBFIGV6J3aEzkJkdi2L4wc8wfGuEkG8BcPDusZzijT7lYHCLXvAObbjJCxraD6MuT0PoicIMms6avpfrNfRqKqZcN9P7EYC/xzAWQ5A5M54kNwbgkUCVdSsaqTvujZuwsOadLoZQ4a/Q== oasis2@MBP-6"

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
