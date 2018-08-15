module "vpn" {
  source = "../modules/vpn"

  private_subnet_id = "${module.vpc.private_subnets[0]}"
  public_subnet_id  = "${module.vpc.public_subnets[0]}"
  vpc_id            = "${module.vpc.vpc_id}"
  admin_user        = "${var.openvpn_admin_username}"
  admin_password    = "${data.aws_secretsmanager_secret_version.openvpn_admin_password.secret_string}"
  key_name          = "${aws_key_pair.cloud_key.key_name}"
  sandbox           = "${var.sandbox}"
}

resource "aws_route53_record" "vpn" {
  zone_id = "${aws_route53_zone.public_hosted_zone.zone_id}"
  name    = "vpn"
  type    = "A"
  ttl     = "300"
  records = ["${module.vpn.elastic_ip}"]

  lifecycle {
    ignore_changes = ["name", "allow_overwrite"]
  }
}

variable "openvpn_admin_username" {
  description = "Username for the OpenVPN Access Server administrative user"
  default     = "openvpn"
}

output "vpn_public_ip" {
  description = "Public facing IP address for the ALM VPN"
  value       = "${module.vpn.elastic_ip}"
}
