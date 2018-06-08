credentials_profile = "jenkins-dev"

accepter_credentials_profile = "jenkins"

alm_account_id = "199837183662"

alm_state_bucket = "scos-alm-terraform-state"

alm_workspace = "alm"

vpc_name = "dev"

vpc_single_nat_gateway = true

environment = "dev"

private_dns_zone_name = "dev.smartcolumbus.com"

vpc_cidr = "10.100.0.0/16"

vpc_private_subnets = ["10.100.0.0/19", "10.100.64.0/19", "10.100.128.0/19"]

vpc_public_subnets = ["10.100.32.0/20", "10.100.96.0/20", "10.100.160.0/20"]

kubernetes_cluster_name = "dev-kube"
