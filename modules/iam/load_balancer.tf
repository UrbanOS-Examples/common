resource "aws_alb_target_group" "keycloak" {
  name     = "keycloak-lb-tg-${terraform.workspace}"
  port     = 8443
  protocol = "HTTPS"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/auth/admin"
    protocol            = "HTTPS"
    matcher             = "200"
    port                = 8443
  }
}

resource "aws_alb_target_group_attachment" "keycloak_private" {
  target_group_arn = "${aws_alb_target_group.keycloak.arn}" 
  target_id        = "${aws_instance.keycloak_server.id}"
  port             = 8443

  lifecycle {
      create_before_destroy = true
  }
}

resource "aws_alb" "keycloak" {
  name               = "keycloak-lb-${terraform.workspace}"
  load_balancer_type = "application"
  internal           = true
  subnets            = ["${var.subnet_ids}"]
  security_groups    = ["${aws_security_group.keycloak_lb_sg.id}"]
}

resource "aws_alb_listener" "keycloak_https" {
  load_balancer_arn = "${aws_alb.keycloak.arn}"
  certificate_arn   = "${var.alb_certificate}"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "redirect"
    redirect {
      port        = "8443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "keycloak_http" {
  load_balancer_arn = "${aws_alb.keycloak.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port        = "8443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
