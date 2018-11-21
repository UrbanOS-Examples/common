resource "null_resource" "create_zone_assocation" {
  provisioner "local-exec" {
    command = <<EOF
      aws route53 create-vpc-association \
      --hosted-zone-id ${data.terraform_remote_state.alm_remote_state.module.iam_stack.aws_route53_zone.public_hosted_reverse_zone.zone_id} \
      --vpc VPCRegion=${var.region},VPCId=${module.vpc.vpc_id}
    EOF
  }
}

resource "null_resource" "associate_vpc_and_zone" {
  provisioner "local-exec" {
    command = <<EOF
      aws route53 associate-vpc-with-hosted-zone \
      --hosted-zone-id ${data.terraform_remote_state.alm_remote_state.module.iam_stack.aws_route53_zone.public_hosted_reverse_zone.zone_id} \
      --vpc VPCRegion=${var.region},VPCId=${module.vpc.vpc_id} || echo "Association already exists"
    EOF
  }
}

resource "null_resource" "delete_zone_authorization" {
  provisioner "local-exec" {
    command = <<EOF
      aws route53 delete-vpc-association-authorization \
      --hosted-zone-id ${data.terraform_remote_state.alm_remote_state.module.iam_stack.aws_route53_zone.public_hosted_reverse_zone.zone_id} \
      --vpc VPCRegion=${var.region},VPCId=${module.vpc.vpc_id} || echo "Association already exists"
    EOF
  }
}
