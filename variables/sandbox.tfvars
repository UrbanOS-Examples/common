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

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4nS6hbs8UkIZGHNNiQmv/v4S4WIQ+EE6kpIdrtbFqsXLvZO1bAtOZXX2V+C5yr7//mLvH3IIiUbxr2tyr0bOvVgcXoQWT49ZDuAcFnaRbJsM73WKLnlRbbvSAdJ+E7Oo4D80Uffw/C5Xayz2bEh7Rx6x22FPyz7mXy5jObIf4d45ydYe29d8cSzRSM26Fc3zcQTEEoqjjS9cUAGYTXigpT0r7VlpOXyO3d4+Y3T71ZFzg0kbjteVOj/wpQj7IBJ7euAXK0Yz3jc4wUCvCMlAA0jw32yDjlHq0QCuAiXVHjRpFqOBkfuBZthKXPntK1vmKZ0E6tnE7xYYSOSRjv3aWsQNQPrtB/sS5TqU3b51zFwlDcLNSQjeUWU6CRU6/ZwvOtlkOvC2oL6I38hxdSWetA+jGuQ7g3/aYre883T3fUABPTlWsO9xtEqqG8J/ysK6R7GtIKS48ahlInfzuVoqe0IMsOGn8xTx1wuYjAdPQMMZYThggekTBl0gWIhObsdk85V1YVuGICI+Wofjx5LjgixHrSnmto6L74jQGYn8oWmtGCbWJfG8VxndsF67TlLPytxJco4rCoDWdSwgWUfYCD1JdTERJVz7HX0XJnS2hsQXB/52p+bNjshFP9+1x0NC6tB+xezqPQg4nNBo8dItR3rqg7GXUDipkDf5fmS7Sjw== smillard@scotts-mbp.lan"

key_pair_name = "eks_key_sandbox_20200127"
