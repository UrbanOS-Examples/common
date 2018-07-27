locals {
  ui_port     = 30060
  stream_port = 30070
}

resource "aws_lb" "cota" {
  name               = "cota-elb-${terraform.workspace}"
  load_balancer_type = "application"
  internal           = true

  subnets         = ["${module.vpc.private_subnets}"]
  security_groups = ["${module.kubernetes.kubeconfig_security_group}"]
}

resource "aws_lb_target_group" "cota_ui" {
  name     = "cota-ui-lb-tg"
  port     = "${local.ui_port}"
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    port                = "${local.ui_port}"
  }
}

resource "aws_lb_target_group" "cota_stream" {
  name     = "cota-stream-lb-tg"
  port     = "${local.stream_port}"
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    port                = "${local.stream_port}"
    path                = "/socket/healthcheck"
  }
}

resource "aws_lb_listener_rule" "socket_path" {
  listener_arn = "${aws_lb_listener.front_end.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.cota_stream.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/socket/*"]
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.cota.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.cota_ui.arn}"
    type             = "forward"
  }
}

resource "aws_autoscaling_attachment" "cota_k8s_attachment" {
  autoscaling_group_name = "${module.kubernetes.autoscaling_group_name}"
  alb_target_group_arn   = "${aws_lb_target_group.cota_ui.arn}"
}

resource "aws_autoscaling_attachment" "cota_stream_k8s_attachment" {
  autoscaling_group_name = "${module.kubernetes.autoscaling_group_name}"
  alb_target_group_arn   = "${aws_lb_target_group.cota_stream.arn}"
}
