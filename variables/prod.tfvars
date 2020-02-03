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

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3hq3xYEwQ/ukXKpoapSOZdclEqT1so1VDs8UAdni/jjH/iPormeI9DMUSLPIHntdHzatYR8WLJnx0N9xGUZ0KfZ/P767qMPynazU8edX0uh6hCeQbg5pPX/ac7a+wrFV/ZCfoE8soQe7Q4LQTTBJ4/n93lMGLwbcN6u05FSxgEYrBDAd55nBvNF6qXF9IhIxq0b0x0GztwxC2E1ge/sPnhOonsrhXsTsMpBztzWyuHXGMI2G6qRB5R6Iq5eHE2mIoRuC7WGFZcxPS4527YJoFtyzu0lygWuC5WZnDKDANEaQqIeq9gLEQoKCSofX8Du7mnOSQKSkiVRhZak41QNuxZ0LNKV6d7LqHsijvSMhvY7i+jA10fofp+KXB3kgl6sGf1icRO8i2o6SWqNQiShBT7EN2VcUZ5QOgfMGFNL11KE/rH2gpyKIOKHodEKopNsmMqK41DYWnkP0xtmFlyuv5OvcsznalyGAZWpCCCJht65C2KrO6604Y+uW35n0Odvo3hOmwI3ALbPbQzVe82+3MiPJwu0EBfdSfRr3QDJC/YNxx8S76JtEZSaZL6S8prnaGAF2cmbOb8YD5uW9qGeeRmMwbZqARU/BsM/7wpp5IjZbFvooG+4T6qycI69oohmsiZMorgpjq63kQb5k8j+ZKARZWzu84Wz7RZc0jWjnyXw== oasis@SmartCity01.local"

key_pair_name = "eks_key_prod_20200203"
