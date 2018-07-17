region = "us-east-1"

environment = "dev"

vpc_name = "dev"

dns_zone_name = "dev.smartcolumbusos.com"

role_arn = "arn:aws:iam::073132350570:role/jenkins_role"

kubernetes_cluster_name = "streaming-kube"

alm_account_id = "199837183662"

alm_role_arn = "arn:aws:iam::199837183662:role/jenkins_role"

accepter_credentials_profile = "jenkins"

alm_workspace = "alm"

vpc_single_nat_gateway = true

vpc_cidr = "10.100.0.0/16"

vpc_azs = ["us-east-1a", "us-east-1b", "us-east-1d"]

vpc_private_subnets = ["10.100.0.0/19", "10.100.64.0/19", "10.100.128.0/19"]

vpc_public_subnets = ["10.100.32.0/20", "10.100.96.0/20", "10.100.160.0/20"]

public_dns_zone_id = "Z25PZI6XYQF2OB"

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRAvH6k7iEeRDz9SQtkH1o8KiUaed/e2hmzTUjA8bhmeWVLPsgCMKIUKR0jdPlvdZ0AmMLXswobsXj08dPgWxUZxoAWIqKCjd969KckydUpBtcb+X2Q+tpOcugBOQSY1H8hgNrdcRKEaUllTfvseJ9pBOYU7j9VuZ608HQhfZw7+aS8wi9o/BJwejtpWdlo6gkxXoIRqDX/ioYg+W6Tc7yoUzAEANwZAy3/3GKWDrh+9jnzR6mEEN48Nuee49wWfP5G0T/v4+Gvux5zioHb3rcmmR9YTkFOiv1poInhXlPdc7Q38yj+z6E+hACNN3rK80YjU0ByaSPltPjqm9ZYmPX"
