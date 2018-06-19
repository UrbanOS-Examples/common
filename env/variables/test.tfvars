environment = "test"

vpc_name = "test"

private_dns_zone_name = "test.smartcolumbus.com"

role_arn = "arn:aws:iam::647770347641:role/jenkins_role"

kubernetes_cluster_name = "streaming-kube"

alm_account_id = "199837183662"

alm_role_arn = "arn:aws:iam::199837183662:role/jenkins_role"

accepter_credentials_profile = "jenkins"

alm_state_bucket = "scos-alm-terraform-state"

alm_workspace = "alm"

vpc_single_nat_gateway = true

vpc_cidr = "10.100.0.0/16"

vpc_azs= ["us-east-2a","us-east-2b","us-east-2c"]

vpc_private_subnets = ["10.100.0.0/19", "10.100.64.0/19", "10.100.128.0/19"]

vpc_public_subnets = ["10.100.32.0/20", "10.100.96.0/20", "10.100.160.0/20"]
