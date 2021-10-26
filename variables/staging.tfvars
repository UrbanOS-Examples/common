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
  "inspector_assessment",
  "elasticsearch",
  "security"
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

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDA5cBzrafU0SrYqOwtVuzFOwlimDeECi2mkCSyqJnqqDSf1q62RMTgw/Z4OVnYCJSBXd849+ukUwlt3qtsaSFc3MZEfrYfRzAE/EVzHif0oefXMhgLXEnwwDcjpHqMxXqKQgeKA9WcnLY1c5kVvKa7B4ja66tjS7qJT3qXqgsqqZ5jBoKaFmve6RZQRwU9QRMTOwC/Y1T5Wq6wU3SrCP1RYNacSwO0DiPeZM4nob5lstV73BPA/Y4LXWqcE3pPLH/HeRXS1D/wKg7OUgUBKFvAxehFUJGd9DCdKSMpGcmgfOlzi0Y5lHdHri3pukV5NO0XeNnN+rxWhZgo9t/EEmKAEAjxzpYENvzHIumX56XJQrEUuzk6+IjOSOYomdiVX5WoDC9GcF7oaJ5+hBYqDfL5xXwxtN5J91ug/xOA/kQubcHpOIWSR7t7TND41y/Tn5TQCpezq8I69nVeshrduSk31K53trS0d7HIIhIO1lnNGyz5xOzlqrWDH0XC36AEzTsrW7okPW8A/bvNcWOBHQ7V+i27Lyadl9yDHXpHBAjNPPZQVMRunTLKLodgSOc0+2UT5Qx+wS9iGmrytP3WtPQeaUbuThdOQcSb/KMi6GNC+dLKIaEdOjkn7awkpBgxN7PpAenvMtu3dQDORXugqzDPqs3D4x27+QbzA62kQP4L3Q== jarred.olson@AMAC02XR4Z3JG5M"

key_pair_name = "eks_key_staging_2020_03_23"

force_destroy_s3_bucket = false

andi_public_sample_datasets = "andi-public-sample-datasets"

max_num_of_workers = 8
min_num_of_workers = 6

max_num_of_memory_workers = 1
min_num_of_memory_workers = 1