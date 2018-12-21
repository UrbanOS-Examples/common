locals {
  lb_rules = [
    {
      name                 = "CKAN"
      condition_field      = "host-header"
      condition_values     = "ckan.*"
    },
    {
      name                 = "Kong"
      condition_field      = "host-header"
      condition_values     = "api.*"
    },
    {
      name                 = "MaintenancePage"
      condition_field      = "path-pattern"
      condition_values     = "/MaintenanceMode/*"
    },
  ]

  lb_target_groups = [
    {
      name                 = "Joomla"
      health_check_path    = "/"
      health_check_matcher = "200"
    },
    {
      name                 = "CKAN"
      health_check_path    = "/"
      health_check_matcher = "200"
    },
    {
      name                 = "Kong"
      health_check_path    = "/ckan/api"
      health_check_matcher = "200"
    },
    {
      name                 = "MaintenancePage"
      health_check_path    = "/"
      health_check_matcher = "200"
    },
  ]
  shared_target_group_arns = "${zipmap(aws_alb_target_group.all_target_groups.*.name, aws_alb_target_group.all_target_groups.*.arn)}"
}

resource "aws_alb_target_group" "all_target_groups" {
  count    = "${length(local.lb_target_groups)}"
  name     = "${lookup(local.lb_target_groups[count.index], "name")}"
  vpc_id   = "${module.vpc.vpc_id}"
  port     = 80
  protocol = "HTTP"
  health_check {
    path                = "${lookup(local.lb_target_groups[count.index], "health_check_path")}"
    matcher             = "${lookup(local.lb_target_groups[count.index], "health_check_matcher")}"
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_alb" "shared_alb" {
  name               = "${terraform.workspace}-scos-shared-elb"
  internal           = "${!var.is_public_facing}"
  load_balancer_type = "application"
  security_groups    = [
                          "${aws_security_group.os_servers.id}",
                          "${aws_security_group.allow_kubernetes_internet.id}"
                        ]
  subnets            = ["${local.private_subnets}"]
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.shared_alb.arn}"
  certificate_arn   = "${module.root_tls_certificate.arn}"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = "${local.shared_target_group_arns["Joomla"]}"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = "${aws_alb.shared_alb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${local.shared_target_group_arns["Joomla"]}"
  }
}

resource "aws_alb_listener_rule" "http" {
  count        = "${length(local.lb_rules)}"
  listener_arn = "${aws_alb_listener.http.arn}"

  action {
    type = "forward"

    target_group_arn = "${local.shared_target_group_arns[lookup(local.lb_rules[count.index], "name")]}"
  }

  condition {
    field  = "${lookup(local.lb_rules[count.index], "condition_field")}"
    values = ["${lookup(local.lb_rules[count.index], "condition_values")}"]
  }
}

resource "aws_alb_listener_rule" "https" {
  count        = "${length(local.lb_rules)}"
  listener_arn = "${aws_alb_listener.https.arn}"

  action {
    type             = "forward"
    target_group_arn = "${local.shared_target_group_arns[lookup(local.lb_rules[count.index], "name")]}"
  }

  condition {
    field  = "${lookup(local.lb_rules[count.index], "condition_field")}"
    values = ["${lookup(local.lb_rules[count.index], "condition_values")}"]
  }
}
