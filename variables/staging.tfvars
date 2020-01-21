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

vpc_name = "test"

role_arn = "arn:aws:iam::647770347641:role/jenkins_role"

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9+lmPon1iXDTxgFlihcrqv3Ugkq/M1SyMrZF/JIcJB6h6j9GS/93sBYLhl60i8DZeymQWd3H65eG46T8gFXC05aRg0OPLiTjDoJFirWpQuefM4zNl3UAWbSmD6ltjEQyXlErqvDEz8RjqSSWP19fKjnAZVdZWmXHQRd2MrxI2MvGnXrH2piVzJWyXNWXMNs7wWyttlD0so1oGOyRVV5kKKYzDOmlDy37xf/6GqgI50BnoDPyn4QwhTtt1DhMJTsadn0wWiqTcMYAA083z9eyiTEUU/KiOIaWghV7gwg4EpcS7tNd2aybv8OuJwUPP4LmVYF1F/sKkvE4EhLpF3/JWhHA9iE03YP5xnYIeisa+HIxpiBLGlguIyRCwUKRuXyxXeS8w57hWDryfjFm9+tUvIXqBtS0W5lc0Jkw4rozvPsR6+XgylVMYzf/LTNJR4pJqMEJKsQd4M/b96eIpsghJZZ1BA47FoUvqyq1qPp1DlF9Uyff38MAgb4OM7LulyS9fwdJgt+BMlPgAUryECdq++OH5KfL3nVxU/O8/1lQJw2Za8+3qZrd8GMIgmIs6wQMQWMGcPDYzqYnxdHZWEHsmH3dnSS9KJEnvX8htr2Oh0EYJlsu3SWlMBeK03e533w38LCJdZjXbOUh/m/pSdOlHiP/bZKY9S3GTdTyOMUwBJQ== oasis2@MBP-6"

vpc_cidr = "10.180.0.0/16"

# Redis Elasticache settings
redis_node_type = "cache.m4.large"

#DNS
root_dns_zone = "staging-smartos.com"

#Alarms
alarms_slack_path = "/services/T7LRETX4G/BDE8Y9SQ3/Amboqt9U8R3IYQgxUlBPkSUY"
alarms_slack_channel_name = "#pre_prod_alerts"
