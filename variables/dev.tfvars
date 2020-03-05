# The enabled_features variable is interpreted by `tf-init` to enable different features by copying them
#   into the root working directory
# If you change the list of enabled features, or if you switch to a different environment
# whose list of enabled_features is different, you must re-run `tf-init` before any other terraform commands.
enabled_features = ["eks-cluster",
  "joomla",
  "lime_db",
  "cloudwatch_monitoring",
  "redis",
  "ses",
  "inspector_assessment"
]

role_arn = "arn:aws:iam::073132350570:role/jenkins_role"

vpc_cidr = "10.100.0.0/16"

# Redis Elasticache settings
redis_node_type = "cache.t2.medium"

#DNS
root_dns_zone = "dev-smartos.com"

#Alarms
alarms_slack_path = "/services/T7LRETX4G/BDE8Y9SQ3/Amboqt9U8R3IYQgxUlBPkSUY"

alarms_slack_channel_name = "#pre_prod_alerts"

#Joomla
joomla_db_instance_class = "db.t3.small"

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7z5+oGFz3MskJMH33GPErgv7HCf62+brPxWbdm6SQKH0LvcZvCZfmtH4STp0ech9/2eglmZCRzwOTTo0cxjrnTZzTZLZTOY08DOBDNPdpH5PLCqIDOvHocEPPilmonXTa9Ca4uXQAPvsWlQ3drwq+WWaCiUem8aONbNaXXMtE52QXcMwx4K5Tiu9LXN0z0C9wA29kv9hPPFNtEzQlL6yCFfZtv/dm6yCtzP7jqPbpLcAfv1rrKCTKQo8zCB4eEPKAnN2NK8S4ZRtZFZX2anOu20kodSaOjSr7kz9qqQurGmCrpgWgwebfQXZJQvvrRIrkQsn8t5585+9yYrifmu6kGvgpGjOxXPVhfywLD/pSI+OIody7zuwli21BiyXjUEiU1jl+aLiZG9h/hCOvAiCd+8goOnYEAz33OHuSUR5zAjAKD2urUjdZFLgKVE5y7nyYjRjXEe1kc2SCs4X/w40bwC6s2A6nkLBQS4hEQ0ZbE3jpJS/DpdWqFYEH+gpt+bXIgCmntFOCvfNV2XmNlHzqg0nCDpDZ0WtQhgDGlDGTC2dmqf/M+YX5vDgOfxPSXegFlt1iD7vqkM3kFYRlOFENUS4rDpyfMKCUUA2Pvyxh9ODMW+G1GbLt0f2abO6e386aaTmdtcm8DfQBMu1P5/YvOkFNa+16sWbg6B9Mws2NOQ== oasis@SmartCity01.local"

key_pair_name = "eks_key_dev_20200224"
