resource "aws_instance" "ckan_external" {
  instance_type          = "${var.ckan_external_instance_type}"
  ami                    = "${var.ckan_external_ami}"
  vpc_security_group_ids = ["${data.aws_security_group.scos_servers.id}"]
  ebs_optimized          = "${var.ckan_external_instance_ebs_optimized}"
  iam_instance_profile   = "${var.ckan_external_instance_profile}"
  subnet_id              = "${data.aws_subnet.subnet.1.id}"
  key_name               = "${var.ckan_keypair_name}"

  tags {
    Name    = "CKAN external"
    BaseAMI = "${var.ckan_external_ami}"
  }
}

resource "aws_alb_target_group_attachment" "ckan_internal" {
  target_group_arn = "${module.load_balancer_private.target_group_arns["${var.target_group_prefix}-Internal-CKAN"]}"
  target_id        = "${aws_instance.ckan_external.id}"
  port             = 80
}

resource "aws_alb_target_group_attachment" "ckan_external" {
  target_group_arn = "${module.load_balancer_public.target_group_arns["${var.target_group_prefix}-CKAN"]}"
  target_id        = "${aws_instance.ckan_external.id}"
  port             = 80
}

resource "aws_route53_record" "ckan_external_private_dns" {
  zone_id = "${aws_route53_zone.private_hosted_zone.zone_id}"
  name    = "ckan"
  type    = "A"
  count   = 1
  ttl     = 300
  records = ["${aws_instance.ckan_external.private_ip}"]
}

resource "aws_route53_record" "ckan_solr_private_dns" {
  zone_id = "${aws_route53_zone.private_hosted_zone.zone_id}"
  name    = "solr.ckan"
  type    = "A"
  count   = 1
  ttl     = 300
  records = ["${aws_instance.ckan_external.private_ip}"]
}

resource "aws_route53_record" "ckan_redis_private_dns" {
  zone_id = "${aws_route53_zone.private_hosted_zone.zone_id}"
  name    = "redis.ckan"
  type    = "A"
  count   = 1
  ttl     = 300
  records = ["${aws_instance.ckan_external.private_ip}"]
}

resource "aws_route53_record" "ckan_external_public_dns" {
  zone_id = "${local.public_zone_id}"
  name    = "ckan"
  type    = "A"
  count   = 1

  alias {
    name                   = "${module.load_balancer_public.dns_name}"
    zone_id                = "${module.load_balancer_public.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ckan_external_alm_dns" {
  provider = "aws.alm"
  zone_id  = "${local.alm_private_zone_id}"
  name     = "ckan.${terraform.workspace}"
  type     = "A"
  count    = 1

  alias {
    name                   = "${module.load_balancer_private.dns_name}"
    zone_id                = "${module.load_balancer_private.zone_id}"
    evaluate_target_health = false
  }
}

variable "ckan_external_ami" {
  description = "AMI of the ckan external image to restore"
}

variable "ckan_external_instance_ebs_optimized" {
  description = "Whether or not the CKAN external server is EBS optimized"
  default     = true
}

variable "ckan_external_instance_profile" {
  description = "Instance Profile for ckan_external server"
  default     = "CloudWatch_EC2"
}

variable "ckan_external_instance_type" {
  description = "Instance type for ckan_external server"
  default     = "m4.xlarge"
}

variable "ckan_keypair_name" {
  description = "The name of the keypair for ssh authentication"
  default     = "Production_CKAN_Key_Pair"
}
