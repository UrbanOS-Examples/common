locals {
  lb_rule_env_prefix = "${terraform.workspace == "prod" ? "" : "${terraform.workspace}."}"

  lb_rules = [
    {
      name             = "Joomla"
      condition_field  = "host-header"
      condition_values = "${local.lb_rule_env_prefix}smartcolumbusos.com"
    },
    {
      name             = "CKAN"
      condition_field  = "host-header"
      condition_values = "ckan.${local.lb_rule_env_prefix}smartcolumbusos.com"
    },
    {
      name             = "Kong"
      condition_field  = "host-header"
      condition_values = "api.${local.lb_rule_env_prefix}smartcolumbusos.com"
    },
    {
      name             = "MaintenancePage"
      condition_field  = "path-pattern"
      condition_values = "/MaintenanceMode/*"
    },
  ]

  target_group_arns = "${zipmap(aws_alb_target_group.this.*.name, aws_alb_target_group.this.*.arn)}"
}

output "target_group_arns" {
  value = "${local.target_group_arns}"
}

resource "aws_alb_target_group" "this" {
  count    = "${length(local.lb_rules) * var.is_enabled}"
  name     = "${var.target_group_prefix}-${lookup(local.lb_rules[count.index], "name")}"
  vpc_id   = "${var.vpc_id}"
  port     = 80
  protocol = "HTTP"
}

resource "aws_alb" "alb" {
  count              = "${var.is_enabled}"
  name               = "${var.is_external ? "${terraform.workspace}-scos-external-elb" : "${terraform.workspace}-scos-elb"}"
  internal           = "${!var.is_external}"
  load_balancer_type = "application"
  security_groups    = ["${var.security_group_id}"]
  subnets            = ["${var.subnet_ids}"]
}

resource "aws_alb_listener" "https" {
  count             = "${var.is_enabled}"
  load_balancer_arn = "${aws_alb.alb.arn}"
  certificate_arn   = "${var.certificate_arn}"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = "${local.target_group_arns["${var.target_group_prefix}-Joomla"]}"
  }
}

resource "aws_alb_listener" "http" {
  count             = "${var.is_enabled}"
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${local.target_group_arns["${var.target_group_prefix}-Joomla"]}"
  }
}

resource "aws_alb_listener_rule" "http" {
  count        = "${length(local.lb_rules) * var.is_enabled}"
  listener_arn = "${aws_alb_listener.http.arn}"

  action {
    type = "forward"

    target_group_arn = "${element(aws_alb_target_group.this.*.arn, count.index)}"
  }

  condition {
    field  = "${lookup(local.lb_rules[count.index], "condition_field")}"
    values = ["${lookup(local.lb_rules[count.index], "condition_values")}"]
  }
}

resource "aws_alb_listener_rule" "https" {
  count        = "${length(local.lb_rules) * var.is_enabled}"
  listener_arn = "${aws_alb_listener.https.arn}"

  action {
    type             = "forward"
    target_group_arn = "${element(aws_alb_target_group.this.*.arn, count.index)}"
  }

  condition {
    field  = "${lookup(local.lb_rules[count.index], "condition_field")}"
    values = ["${lookup(local.lb_rules[count.index], "condition_values")}"]
  }
}

variable "is_external" {
  description = "should the load balancer be external"
}

variable "is_enabled" {
  description = "If true, the resources defined in this module are created."
}

variable "target_group_prefix" {
  default = "PROD"
}

variable "vpc_id" {
  description = "ID of the VPC"
}

variable "certificate_arn" {
  description = "ARN of the https certificate"
}

variable "security_group_id" {
  description = "id of the sercurity group"
}

variable "subnet_ids" {
  type        = "list"
  description = "list of subnet ids to associate with the load balancer"
}
