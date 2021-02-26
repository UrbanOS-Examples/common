locals {
  host_zone_acct = var.alm_account_id                   # ALM account where the reverse lookup zone resides
  assume_role    = element(split("/", var.role_arn), 1) # The 'admin' role is called admin in sandbox and jenkins everywhere else :(
  zone_id        = data.terraform_remote_state.alm_remote_state.outputs.reverse_dns_zone_id
  cli_flags      = "--hosted-zone-id ${local.zone_id} --vpc VPCRegion=${var.region},VPCId=${module.vpc.vpc_id}"
}

module "create_vpc_association_authorization" {
  source = "github.com/opetch/terraform-aws-cli-resource"

  account_id  = local.host_zone_acct
  role        = local.assume_role
  cmd         = "aws route53 create-vpc-association-authorization ${local.cli_flags}"
  destroy_cmd = "aws route53 delete-vpc-association-authorization ${local.cli_flags}"
}

module "associate_vpc_with_zone" {
  source = "github.com/opetch/terraform-aws-cli-resource"

  # Uses the default provider account id if no account id is passed in
  role        = local.assume_role
  cmd         = "aws route53 associate-vpc-with-hosted-zone ${local.cli_flags}"
  destroy_cmd = "aws route53 disassociate-vpc-from-hosted-zone ${local.cli_flags}"

  dependency_ids = [module.create_vpc_association_authorization.id]
}

