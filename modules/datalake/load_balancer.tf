resource "aws_alb_target_group" "datalake" {
  name     = "datalake-lb-tg-${terraform.workspace}"
  port     = 8443
  protocol = "HTTPS"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/${local.ambari_gateway_path}/knox/ambari"
    protocol            = "HTTPS"
    matcher             = "200"
    port                = 8443
  }
}

data "aws_instance" "datalake" {
  filter {
    name   = "tag:CloudbreakClusterName"
    values = ["${null_resource.cloudbreak_cluster.triggers.cluster_name}"]
  }

  filter {
    name   = "tag:instanceGroup"
    values = ["management"]
  }

  tags {
    trigger = "${null_resource.cloudbreak_cluster.id}"
  }
}

resource "aws_alb_target_group_attachment" "datalake" {
  target_group_arn = "${aws_alb_target_group.datalake.arn}"
  target_id        = "${data.aws_instance.datalake.id}"
  port             = 8443
}

resource "aws_alb" "datalake" {
  name               = "datalake-lb-${terraform.workspace}"
  load_balancer_type = "application"
  internal           = true
  subnets            = ["${var.subnets}"]
  security_groups    = ["${var.cloudbreak_security_group}"]
}

resource "aws_alb_listener" "datalake_https" {
  load_balancer_arn = "${aws_alb.datalake.arn}"
  certificate_arn   = "${var.alb_certificate}"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.datalake.arn}"
  }
}

resource "aws_lb_listener_rule" "datalake_helper" {
  listener_arn = "${aws_alb_listener.datalake_https.arn}"

  condition {
    field  = "path-pattern"
    values = ["/"]
  }

  action {
    type             = "redirect"
    target_group_arn = "${aws_alb_target_group.datalake.arn}"

    redirect {
      path        = "/${local.ambari_gateway_path}/knox/ambari"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_route53_record" "datalake_dns" {
  zone_id = "${var.datalake_dns_zone_id}"
  name    = "datalake"
  type    = "A"

  alias {
    name                   = "${aws_alb.datalake.dns_name}"
    zone_id                = "${aws_alb.datalake.zone_id}"
    evaluate_target_health = false
  }
}
