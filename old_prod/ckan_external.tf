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
  target_group_arn = "${module.load_balancer.target_group_arns["${var.target_group_prefix}-Internal-CKAN"]}"
  target_id        = "${aws_instance.ckan_external.id}"
  port             = 80
}

resource "aws_alb_target_group_attachment" "ckan_external" {
  count            = "${var.alb_external}"
  target_group_arn = "${module.load_balancer_external.target_group_arns["${var.target_group_prefix}-CKAN"]}"
  target_id        = "${aws_instance.ckan_external.id}"
  port             = 80
}

resource "aws_route53_record" "ckan_external_dns" {
  zone_id = "${aws_route53_zone.private_hosted_zone.zone_id}"
  name    = "ckan"
  type    = "A"
  count   = 1
  ttl     = 300
  records = ["${aws_instance.ckan_external.private_ip}"]
}

resource "aws_route53_record" "ckan_solr_dns" {
  zone_id = "${aws_route53_zone.private_hosted_zone.zone_id}"
  name    = "solr.ckan"
  type    = "A"
  count   = 1
  ttl     = 300
  records = ["${aws_instance.ckan_external.private_ip}"]
}

resource "aws_route53_record" "ckan_redis_dns" {
  zone_id = "${aws_route53_zone.private_hosted_zone.zone_id}"
  name    = "redis.ckan"
  type    = "A"
  count   = 1
  ttl     = 300
  records = ["${aws_instance.ckan_external.private_ip}"]
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
  default     = "m4.2xlarge"
}
variable "ckan_keypair_name" {
  description = "The name of the keypair for ssh authentication"
}