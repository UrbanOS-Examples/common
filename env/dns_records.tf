/*
To add a DNS record requires two records - one for private DNS and one for public
public zone is ${aws_route53_zone.public_hosted_zone.zone_id}
private zone is ${data.terraform_remote_state.alm_remote_state.private_zone_id}
*/

resource "aws_route53_record" "jupyterhub_dns" {
  zone_id = "${aws_route53_zone.public_hosted_zone.zone_id}"
  name    = "jupyter"
  type    = "A"
  count   = 1

  alias {
    name                   = "${aws_elb.jupyter_elb.dns_name}"
    zone_id                = "${aws_elb.jupyter_elb.zone_id}"
    evaluate_target_health = false
  }
}

/*
This DNS record is here for compatibility with the manually managed zones
until we can migrate them over
*/
resource "aws_route53_record" "jupyterhub_dns_compatibility" {
  zone_id = "${var.public_dns_zone_id}"
  name    = "jupyter"
  type    = "A"
  count   = 1

  alias {
    name                   = "${aws_elb.jupyter_elb.dns_name}"
    zone_id                = "${aws_elb.jupyter_elb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "alm_jupyterhub_dns" {
  provider = "aws.alm"
  zone_id  = "${data.terraform_remote_state.alm_remote_state.private_zone_id}"
  name     = "jupyter${local.env_dns_prefix}"
  type     = "A"
  count    = 1

  alias {
    name                   = "${aws_elb.jupyter_elb.dns_name}"
    zone_id                = "${aws_elb.jupyter_elb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_zone" "private" {
  name   = "${terraform.workspace}.internal.k8s"
  vpc_id = "${module.vpc.vpc_id}"
}
