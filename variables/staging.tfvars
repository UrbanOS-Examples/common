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
  "inspector_assessment"
]

vpc_name = "test"

role_arn = "arn:aws:iam::647770347641:role/jenkins_role"

vpc_cidr = "10.180.0.0/16"

# Redis Elasticache settings
redis_node_type = "cache.m4.large"

#DNS
root_dns_zone = "staging-smartos.com"

#Alarms
alarms_slack_path = "/services/T7LRETX4G/BDE8Y9SQ3/Amboqt9U8R3IYQgxUlBPkSUY"

alarms_slack_channel_name = "#pre_prod_alerts"

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDP0qf/R9380ma4TFab9aaaX1TLLqcS8vfP28wgDy+21dlgkRwWpt1iZ3AF7c+RC7X3y2av/M8dM+zqrdQN2phpYDyReD/c72qZCE+L9r2pa63QxAclXtedH3MHw/EgRxdt27UjCm1SrtYdOCa+9jIDxj0b11soVQy/zQvTmr+dXMkrcAFPVjnU3KRAg2DIdxmA0rLogYym+ygFO9RyVdN4ggsCEwFRBiaw/0gOBEc0SO+HeQBDzPlu/AgU0jDxc1bDHxmEdhZ1uLxFnWk73RGoBriz70XpnHyNzbKfC6ozETIs7EMTr//wWMaKM3pk1OD5iWAZQxadzXyfeRUgknvbsxqyMWwbvhu1zmYXjQ2jQbwk4hkxLAXWB7wZIQH6EHjThB6LKDhCET1LgrcOQWMi6D+q7aWpBilTyS4/CkF5bkcGpUB4+8IrKedJuYm1mwMgYna1ZYCJM1L2n50KOTT5qpetMGQG1yJsac6TilIBYCIAzobfl/SPhH8zqVhiuiuI6LNbC1L00hbsgPpQDotr34ytiBgQI3+XOsBMlrpjGDNUclYTeVxt3xpG0AgZFKDW0nk8fNbTWNeFk8UdKxRz79Le1itWcupK+XjP/Xmb8uGVIMw1o1gsMamArO46Xgij6+sNUSUBa90MebkQhgMJsK/pZGqmWgzkDYXMRF6p2w== oasis@SmartCity01.local"

key_pair_name = "eks_key_staging_20200224"

force_destroy_s3_bucket = false