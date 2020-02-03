# the enabled_features variable is interpreted by `tf-init` to enable different features by copying them
#   into the root working directory
# if you change the list of enabled features, or if you switch to a different environment
# whose list of enabled_features is different, you must re-run `tf-init` before any other terraform commands.
enabled_features = [
  "eks-cluster",
]

alm_account_id = "068920858268"

alm_state_bucket_name = "scos-sandbox-terraform-state"

role_arn = "arn:aws:iam::068920858268:role/admin_role"

alm_role_arn = "arn:aws:iam::068920858268:role/admin_role"

#EKS Version
cluster_version = "1.13"

#EKS Workers
min_num_of_workers = 1

k8s_instance_size = "t3.medium"

#Kafka EKS Workers
min_num_of_kafka_workers = 1

max_num_of_kafka_workers = 3

# Redis Elasticache settings
redis_node_type = "cache.t2.medium"

#DNS
internal_root_dns_zone = "sandbox.internal.smartcolumbusos.com"

root_dns_zone = "sandbox-smartos.com"

is_sandbox = true # Leave this true

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/N47lMEhBq4PYKYHFmp5qpQ3q0YwNHOROplnvawAR0DF0apgfmn5+hfUHolx2s4vzFYrah4fISQFQnRiS7znZ5IR/UidZJ0UoAq2puWMvtg+A5u0ZCR/4PsWi2xPOvVeDvKDrolSrCYySfohbWv/NsufGgc6himwrJ25MUIaCf3Bfz85oGFLYkn4k/Ghoa0Ll6rKXn5RbkrsQU6LPAlUBwmzZM/oUKCzyTNtVlgjNIjXKIddRq9LZUI0wkgSR3G8Dqi4gYt3kqeAw0+MlvrIzQlCOulmCl5Pe+9Yu7goZocn9aXiC4/FPr/SwSZvFB+ed4V6c13bT5fg76RRImcRdKEs3WjG/gI750FBbyv8vLDO2eNeBz5qrxK5Yf9PIfyomIYFl1zcng9uitZcVqkxvKLWxIEdZXpcFDnizZhpHlGv1cv1UuRT21gCziIwgfmPGYAHMYSfWgIpUCQ4snUaycj7nL5iOPLPvG8xN5JZWbM/kTv6IzkWpxSslqozqMDlRaWaG/UTO8HhSLpWuAikQ4IAihZrC8Wys8ZCCS+lio5BiJR8FOG72hxPJqJopVMUOFT8+mlt70+39ALXnxP+q3VEmQCU7bvnOZRRy4VhhWUtLmhdZyJEtU0gpIBavMLIBlCnaAKJp5UOmmFYozB/pugi1lmbjtzc5h4ehu3D3Qw== oasis@SmartCity01.local"

key_pair_name = "eks_key_sandbox_20200203"
