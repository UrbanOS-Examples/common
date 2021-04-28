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
  "inspector_assessment",
  "data_science_stack",
  "elasticsearch",
  "security"
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

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEwoOFbcKsWLdJHQQq1TIWgwx5nE7drG6WybCmKbCI/XQtVDdwW0PW3mS3+NtXdPtnHABOyp8vOgxll1vR4v3t7i/qhUfDRyifNJxKV9cX9gE0bJ4JKrzLkFEhHaGFMMmzCBguNgZrdN0m0TGmt/hYBn4XxiRP9EbOdYsLgnWC2ao66ZmMvFasB4FHRZKIcxhR0ljoomIJjzW0xwG0bWjRYEJu9U9bykTi29Jo9XwzEzaT3lCtevczfKQyJRcWXbcAGwNQPMzwHUHkESXwnoZ621K35dT48D9nH1esm5wwqbZ4SGZDAZcoB4pZxAfN8hDG+SBK1QlIG82HQlsu15/EAmg/rbkRZLU3mNE655Cem9uUAF0BeJra1XgE4GmSbpCkfRnB7urIb3UbwmMqhCCJSjOhXjlF2G3lInmavfWvFKjpfn1vdjJ0DobC311tahSgG9LjxxfGKwP1D87q6/WwamO1F7IMkQjxRfsn7f8XFGKxBK0kbmk6bkjVw6CPCPkqY5y3AvbNnTQs+JUByjlwfMqQR6ASpX/tnusYsdL/EyoOY8/7DSxXKWoFv5WqsIc266o8RNVp0dQiIvwcfyMFD3UhKOPJfCK/Ei+VMe0T3hCKlC9q8ztmI2qmxUthmJiFECrrGjbGdBQia0XYsGSKNtrwIEFDxgHl6Iws6bSiSw== jarred.olson@AMAC02XR4Z3JG5M"

key_pair_name = "eks_key_dev_2020_03_23"

force_destroy_s3_bucket = false

andi_public_sample_datasets = "andi-public-sample-datasets"

# EKS
cluster_version = "1.16"

eks_ami_version = "20210329"