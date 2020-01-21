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

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8KozRbienyWYog17L6ltEumm2lDuUo1rBdi8QyXeLx+7N9HZxzAWxRq/0V0G4kVSxlOMFErjBNwoPIVhBrU+CeIyjHqPDVanZ35wZwK2Iiv3fYmYH5+k/fzK7foiXq6iozew6XLoIyEZ+f4V0T++0aJ2OJe8rtMzonIVUyvRXwm/BiPJ6SoSfDS/a0Eqna+I3uvBBbnPZ+UlmVfQR2zfT5vzAE2M9VVsbQPv4NQnVo/pEc7hqG3C8ZjAM1LoTv4VtRa1M4r7OVf5Jvkx6LPUcVb6oazulZgzIWKZk8orIi+awX6KcJFoGNUz88dRKMQQDBLEsgMut5zzfDy06lcwLcKTE6xXXf5eNIgqX7UtrBgUfgkVKAS5FX6FeN+NdWgIDD5wIdMBL883qWomZK8A8k9ZkKh5FNshkELCDfUdcxB8f7lCk4c4qKTYtED524tk+G8qV+yRJY9ArySQmJLrK1WgVfC9pV2RDaQUN57daEScuXYeGLcdkWxvwZYxaIDhqlo/6N65UAmEkQ6+IHcXMPvU7rKwRrymafP62hA2GZgBK0DpweTvwPFeGaqApBxvT2zqbw+3heWzVHcUHehxfs2AQEWCg4T97z8M1pEmNQKZfxeLNfXHKMl+PKVqPWu4g2Ngp0prjnDZzJB67sTXL7b4qOSz5k7H0CSob+KU7pw== oasis2@MBP-6"

vpc_cidr = "10.200.0.0/16"

#DNS
prod_dns_zone = "smartcolumbusos.com"

# Redis Elasticache settings
redis_node_type = "cache.m4.large"

#Alarms
alarms_slack_channel_name = "#prod_alerts"