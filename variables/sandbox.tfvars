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

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCZ6W2RFcbuKDTu031pQRwmnV9rNqicYveZgts169X42i5xcQvVrUzCcBMRFEoEUrGP+MPb/NtCFCA7wdY/KvB1Un+RrqaFKBdmaZN2w4000AQfVFfxRKlYf0gqo1I4Daj6Y3OlOoGgsjVd4hMrfd1WhHKupse+yA8xEDVKmnkiXhFchu53knW+8bQ7EwYMcoGyulMg1meK/fKQi5L7fDaGspUL6FHSl32wc/YJW9pQcgn3E/mafF9bOK13hqsfd5xc8qMOeiAX/PoE66cZ8VumQUb5h3TWWObmkNDQoShpck7s1IoloPtPaCg26ihcwlUYy17dh6NgFjzkjiG/jkjw2pGg1OZ2jC8KAYpxOXJk0bfYafCKGKOasvkigtPwMVAQIVINUCcCNq8EcyveUlovWqbQOUnhB3Wuam4IbhDfK/RhCr4gopBKeTi+yU1T+f1Qbi/45pShlhOLFhQ9fveeFXtrYjc5BPmNNbpHcw3G5JsT+O67KpgdPhGi3JIpiYy8oCakFYsEHmf/8lQbow4KTBlh5O7UBaM1wydN272WiWf62fzUJt7z0nEInlPVehd34J03YQ+j9XwJTaMmGXCYCCpQtwvEtVXVykP9UPobbAjnBnxaCg2CNAyWPjU5Xv5Q590b7tSI/6cb/2L/RE3w5TqyS7cA0zP7AnZuQvbyzw== oasis2@MBP-6"

key_pair_name = "eks_key_sandbox_20200122"
