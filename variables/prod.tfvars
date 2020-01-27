# the enabled_features variable is interpreted by `tf-init` to enable different features by copying them
#   into the root working directory
# if you change the list of enabled features, or if you switch to a different environment
# whose list of enabled_features is different, you must re-run `tf-init` before any other terraform commands.
enabled_features = ["eks-cluster",
  "joomla",
  "lime_db",
  "cloudwatch_monitoring",
  "redis",
  "ses",
]

role_arn = "arn:aws:iam::374013108165:role/jenkins_role"

vpc_cidr = "10.200.0.0/16"

#DNS
prod_dns_zone = "smartcolumbusos.com"

# Redis Elasticache settings
redis_node_type = "cache.m4.large"

#Alarms
alarms_slack_channel_name = "#prod_alerts"

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClx5lwTDsdKrUWLM+BfqGm12wJzLuEhybO1hIwTVZwU+5g3vFdeJZa2raDgV1KF0XkwUEVAJ1MXN0slSiWEmcFdbVcbobRBdmGeRHpq92TEjnpgx3EnbBdMfLE34UH1tk9U7sVhaPKGDT4/6+WUYmKj8E86S21Pku32kXlC0uBiaefQxsJlgMaBOubBHP8wG4ciRT7CF1o09AUcxscXsSDlaoU/AJvGBt9A23360GYsUXk5lIQK9QvqucUHm6jgjAGZFpfsPHAiYryr77OH5zHr+tSf348vYAhEgrj+aW6JbNbNTnk4qSSSmEhsXoy+itMBDnzKlLDoUwRqGwEXWhWuYhO1Dj6FRf1hQCSw/+VfLxoRXt6hGcMHF6FufGEbC0nPcqvoxgWSAtSFII+8lGOhfz2vB7kLL2uGdEfj4Qy0frU9/880wtZ7HsqUlpml6OS3v31qXuwpik7fmbEFnzvDswOP2p5oDaL/60cu58VOPFsajWJOESWYBY7ieTO2FVcdYawJoaX8FgPwisyiomtbG9rd5nTlTztmhB0njnDB5aIwPcsouFNtmrL12rm/XLsLc/LXpFJ2RARJIvmGkGZTAg//Q6XDFJIKPkSImCSz6V3ZbjwZF1yquy3c3XvLW7BR0RIMmP/o7+pHuhvKXkABCwk986fjEnhsf2UwY4ddQ== smillard@scotts-mbp.lan"

key_pair_name = "eks_key_prod_20200127"
