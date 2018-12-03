locals {
  ambari_port = "8443"
  metrics_port  = "6188"
}

resource "aws_alb_target_group" "datalake" {
  name     = "datalake-lb-tg-${terraform.workspace}"
  port     = "${local.ambari_port}"
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
  }
}

resource "aws_alb_target_group" "datalake_metrics" {
  name     = "datalake-metrics-lb-tg-${terraform.workspace}"
  port     = "${local.metrics_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/jmx"
    protocol            = "HTTP"
    matcher             = "200"
  }
}

resource "aws_alb_target_group_attachment" "datalake" {
  target_group_arn = "${aws_alb_target_group.datalake.arn}"
  target_id        = "${data.aws_instance.cb_cluster_management.id}"
  port             = "${local.ambari_port}"
}

resource "aws_alb_target_group_attachment" "datalake_metrics" {
  target_group_arn = "${aws_alb_target_group.datalake_metrics.arn}"
  target_id        = "${data.aws_instance.cb_cluster_management.id}"
  port             = "${local.metrics_port}"
}

resource "aws_alb" "datalake" {
  name               = "datalake-lb-${terraform.workspace}"
  load_balancer_type = "application"
  internal           = true
  subnets            = ["${var.subnets}"]
  security_groups    = ["${var.cloudbreak_security_group}", "${aws_security_group.datalake_metrics.id}"]
}

resource "aws_alb_listener" "datalake_metrics" {
  load_balancer_arn = "${aws_alb.datalake.arn}"
  port              = "${local.metrics_port}"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.datalake_metrics.arn}"
  }
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
