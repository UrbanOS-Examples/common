# the enabled_features variable is interpreted by `tf-init` to enable different features by copying them
#   into the root working directory
# if you change the list of enabled features, or if you switch to a different environment
# whose list of enabled_features is different, you must re-run `tf-init` before any other terraform commands.
enabled_features = [
  "eks-cluster"
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

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWRogUKlMCf+T/NOvlZZIIRbcAlAkpTA9QQkE3sho31EBMQKM681CxOBSYse9NH6MLsh70097WjR5kTV4AmcxRK3sO2Ez6GX0dYEf3TFokjrQ5nHX+7RUplD4yOq1ISbZux9SwMG+ktnYt/ZH3OO+78BjmN4CGQARZdrodpX6XtJ5asH6+F9U2JnIofCUiCmkZF+4n5/1HKyw3ytDNsJENbEyGlByESxTTvqWc8N8pyTqBRkdqkViybDYyJcT2nqJi5EtgckuA2D8cdBI6BMSzdWbC6R92mMPDgc+5hOW14V8dTwvTgajvxoVlFPbD95sqGXnF0GxSyym/VHltbfpX3hcBUkl1eF6ChjmKCGxhZsM2ILQNGNVgKHX1zy0mslxpw2sN/Za0D4Dsc0ao4J+2W/r3mO1Mp7wtJzK2sAmMNgxz5wpOnfmxAyUPB8l9kAhq6tl11Xrj1hJMMFsI4/HwW81PVEWHCv3AS0YAR1dhb1I5rjaaqqcQQysSGK/PRURjCwgUOYujqoFRNTjZYczuGBtRBSitt/ntldco9PjI9IbbsW6m4Ai6LBxVkgqRo4lkV87qyXMJ95Pa2G0LlS4IN+MDTPNib1M2ENxXzW7ueZCatOFSJU1we8tBS2kC4wiDLiAFOIvCxKlSgna3icjJhYwtglV0mI387/1rrt1p+w== oasis@SmartCity01.local"

key_pair_name = "eks_key_sandbox_20200224"
