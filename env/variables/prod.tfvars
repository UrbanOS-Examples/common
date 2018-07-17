vpc_name = "prod"

dns_zone_name = "smartcolumbus.com"

role_arn = "arn:aws:iam::374013108165:role/jenkins_role"

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
