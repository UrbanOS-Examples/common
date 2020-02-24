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

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDkKXhbFONq56pWDaCRcEHUfH5aTaZ2VEqh4VXJiXVluefN3qTx2/+p3aZ633aFiblxGK3er5yAj/tQyzvmxtPy80pbfJSruht8q9V1YJXp/N6xcoblzq69xVt/DVjLAuF3s3LkToeRMGFEmGzVW9U8AxSMYj0AnfjsnT+MVJ9n9VNy4WhQ9QUy3lgUWh6kS4GvtlM+LoTGbS1cDhiJ5iK+CzBv54A/p9wLRS/zXFnzQYxfkS1Wp7UchX4hXM0vREb+nCZbBe6/hWRV3/vALSuEt9BQxudIEpqCYsKlfyRje5Vy/79LUUq3kqIikbfvFp9+ZZLaqMwMk8v2EjkkVVZK504uxZlk/UhnbZROUQ2PYTRqn+qiZ+Kp8Wh+4qmJ7x2Sr/wtLrzNvNu7ZruhYd3k7WzSJwUQKCVSMgvL8XlKFX1Ch2pUxYj5h3kf9gKMHY4j36U5FFRlvRcSrlef9LuIhAUZDX2CqqgdyUDkEuNE3q3Sqsf51AXfE+k/P4lOzW2uGDk2a19tjEIAVgAIcjZ7Px/Tp2Yi1B1axf6mZ8pLUDHR5ifFtKrChyOaw3y9M84n24xLPyQ7i4qAGoyg2PwKL/QLoiQy5tC8U1c6Bf4z1Xo8aMRCZ978A8G/UUE+1FIB0D4wj1eP5Dv0lKAB3+kzvH+BYwgxH4GKvNG9Tsxe/Q== oasis@SmartCity01.local"

key_pair_name = "eks_key_prod_20200224"
