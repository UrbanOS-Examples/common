credentials_profile = "sandbox"

accepter_credentials_profile = "sandbox"

vpc_name = "sandbox-dev"

vpc_single_nat_gateway = true

dns_zone_name = "sandbox.smartcolumbus.com"

alm_account_id = "068920858268"

alm_workspace = "sandbox"

alm_state_bucket_name = "scos-sandbox-terraform-state"

vpc_cidr = "10.100.0.0/16"

vpc_private_subnets = ["10.100.0.0/19", "10.100.64.0/19", "10.100.128.0/19"]

vpc_public_subnets = ["10.100.32.0/20", "10.100.96.0/20", "10.100.160.0/20"]

kubernetes_cluster_name = "sandbox-kube"

role_arn = "arn:aws:iam::068920858268:role/admin_role"

alm_role_arn = "arn:aws:iam::068920858268:role/admin_role"

kube_key = "~/.ssh/id_rsa.pub"

public_dns_zone_id = "Z8ERD8071HP70"
