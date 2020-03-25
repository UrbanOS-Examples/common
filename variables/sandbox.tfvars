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

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCrnk5HU0rn3fe5MksDs+cz7zxl9+xbzOVNz+Rl1AjTRC58xm1zatkrUjtraQY2A/0zRvfTalSdheAhxXgf8IcKMsbytrInyqkIz1kOnciAuF/RanHyoYxaQE/N/klbjcJPLeglm+s8pXIVBwsTIe4B+sjwkkLEoiVhrVllj7z4XsptE8ko1+nGJFVY0GM27AKtt+TZvRTcj3/2d6BiUs0QLD4No11VsAP41l4FxE7ywtZWDY3S3H/Ii+/d7Z9Z8abmwwLEPeNnDQ1BP7a1RCCfKGR5Crlbo6n6oIREyT8cHGvfsZVkgjjIF43Zj5L6mQBra20vVWt1Wf9a3AQZVWxLkRmicuqakodKdp8Liuj569u6MH//vnXQ0XXDfyyKgsigIw6NHBJkY0jRZakE9/fM+a4BOLxx5IK9q+CaIlPIaNno6DEHi+k8vG69nDI39n1UJfcjfiZdeZ7PX/McgxxNR7yZuiUqtflaWx9S8rxcz04eJbkDQFuabGTZsCmgtcauENEFBtISiYVEUaBbS7uywLdt6FlASHoYyFvO/xIpPdB2VUZo6ARA0P5I5K96k4UrkT02L09/I3hD/LbC+T73RMCLmPptiumxrkuL91ZmWhkZseguybfZJJe3ZrdpGnt94/fB+odbrkEt2UsATBEHB1dBdwQy5UT1/QL3ho48LQ== jarred.olson@AMAC02XR4Z3JG5M"

key_pair_name = "eks_key_sandbox_2020_03_23"

force_destroy_s3_bucket = true