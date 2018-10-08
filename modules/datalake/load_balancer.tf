resource "aws_alb_target_group" "cloudbreak" {
  name = "cloudbreak-lb-tg-${terraform.workspace}"
  port = 443
  protocol = "HTTPS"
  vpc_id = "${var.vpc_id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/cb/info"
    protocol            = "HTTPS"
    matcher             = "200"
    port                = 443
  }
}

resource "aws_alb_target_group_attachment" "cloudbreak_private" {
  target_group_arn = "${aws_alb_target_group.cloudbreak.arn}"
  target_id        = "${aws_instance.cloudbreak.id}"
  port             = 443

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ "null_resource.cloudbreak" ]
}

resource "aws_alb" "cloudbreak" {
  name = "cloudbreak-lb-${terraform.workspace}"
  load_balancer_type = "application"
  internal = true
  subnets = ["${var.subnets}"]
  security_groups = ["${aws_security_group.cloudbreak_security_group.id}"]
}


resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.cloudbreak.arn}"
  certificate_arn   = "${var.alb_certificate}"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.cloudbreak.arn}"
  }
}

resource "aws_route53_record" "cloudbreak_public_dns" {
  zone_id = "${var.cloudbreak_dns_zone}"
  name    = "cloudbreak"
  type    = "A"

  alias {
    name                   = "${aws_alb.cloudbreak.dns_name}"
    zone_id                = "${aws_alb.cloudbreak.zone_id}"
    evaluate_target_health = false
  }
}
