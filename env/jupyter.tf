locals {
  jupyter_port = 30001
}

resource "aws_elb" "jupyter_elb" {
  name = "jupyter-elb-${terraform.workspace}"

  internal = true

  subnets         = ["${module.vpc.private_subnets}"]
  security_groups = ["${module.kubernetes.kubeconfig_security_group}"]

  listener {
    instance_port = "${local.jupyter_port}"

    instance_protocol = "TCP"
    lb_port           = 80
    lb_protocol       = "TCP"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:${local.jupyter_port}"
    interval            = 30
  }
}

resource "aws_autoscaling_attachment" "jupyter_k8s_attachment" {
  autoscaling_group_name = "${module.kubernetes.autoscaling_group_name}"
  elb                    = "${aws_elb.jupyter_elb.id}"
}

module "jupyter_dns_records" {
  source                = "../modules/dns_records/"
  name                  = "jupyter"
  dns_name              = "${aws_elb.jupyter_elb.dns_name}"
  lb_zone_id            = "${aws_elb.jupyter_elb.zone_id}"
  public_zone_id        = "${aws_route53_zone.public_hosted_zone.zone_id}"
  compatability_zone_id = "${var.public_dns_zone_id}"
  alm_zone_id           = "${data.terraform_remote_state.alm_remote_state.private_zone_id}"
}
