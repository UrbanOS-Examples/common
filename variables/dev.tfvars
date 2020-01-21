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
                   ]

role_arn = "arn:aws:iam::073132350570:role/jenkins_role"

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEzyFGkMRGxqkxLCnrinox4DXtHcnV3ei0OOCXjeomNm7hF7WNmgxmph4tFpNiObcOQEkc/etMriQ3MYTG4NC2w1pBuL63p8weN4lGqR8BnWJM3Q+ygNx0565wDSeiijocYaPlAZSXPIF6dwnpeGO5awY2KzF08b4StkAV5BCV4UJRgW2yfTi5c7DPHtwttSn9gu98Qhv6SRQs6+2f2hN4iSnDtefMVE8oEJXmnybUly9hIxlgfALL+LivmYHi5sOUhXzgNk9vYtI5/V6rKiw7+JxhjJEJ8l0TkVd64evX1UTRa3EO2tDyWahya+v32B/aFoFDbjYkB/pLXsGYjmVnLRbJxdn59hNlZ9NxANHEki+CwO3adaE1g3ZypaDU5VAPYNv5bHFnuOEhQ5Wa5BD3AazzT+GPSrAQsp8T3uAfAS7tIeDjNvGvj82YfjmoabTODUshNqASnbuBFVAxviL1mt6Ca4wZXM4gQU0qRtNNMRNBrJl6DROw++ze2owfZJ+lcAHOPnXhLLa8D3sAqKZkfJS8tqHLVJ+Q3hqbSdDXyAty2WOO6T52usWZMvEgZfRK/Kx9KMdSItdEU9YmN+IricxdI1VPoYpnY7SuN+7TnsUVWJHMly0pin9P10Ztt7jmkPxl0EWYBLDzy8LhWTGWVGIO1Ul444j0gLc+yNJ9hQ== oasis2@MBP-6"

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