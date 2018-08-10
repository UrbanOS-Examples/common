locals {
  fqdn_suffix = "${terraform.workspace}.${var.root_dns_zone}"

  lb_rules = [
    {
      name             = "Joomla"
      condition_field  = "host-header"
      condition_values = "${local.fqdn_suffix}"
    },
    {
      name             = "CKAN"
      condition_field  = "host-header"
      condition_values = "ckan.${local.fqdn_suffix}"
    },
    {
      name             = "Kong"
      condition_field  = "host-header"
      condition_values = "api.${local.fqdn_suffix}"
    },
    {
      name             = "MaintenancePage"
      condition_field  = "path-pattern"
      condition_values = "/MaintenanceMode/*"
    },
  ]

  target_group_arns = "${zipmap(aws_alb_target_group.all_target_groups.*.name, aws_alb_target_group.all_target_groups.*.arn)}"
}

resource "aws_alb_target_group" "all_target_groups" {
  count    = "${length(local.lb_rules)}"
  name     = "${var.target_group_prefix}-${lookup(local.lb_rules[count.index], "name")}"
  vpc_id   = "${var.vpc_id}"
  port     = 80
  protocol = "HTTP"
}

resource "aws_alb" "alb" {
  name               = "${var.is_external ? "${terraform.workspace}-scos-external-elb" : "${terraform.workspace}-scos-elb"}"
  internal           = "${!var.is_external}"
  load_balancer_type = "application"
  security_groups    = ["${var.security_group_ids}"]
  subnets            = ["${var.subnet_ids}"]
}

resource "aws_alb_listener" "https" {
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
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${local.target_group_arns["${var.target_group_prefix}-Joomla"]}"
  }
}

resource "aws_alb_listener_rule" "http" {
  count        = "${length(local.lb_rules)}"
  listener_arn = "${aws_alb_listener.http.arn}"

  action {
    type = "forward"

    target_group_arn = "${element(aws_alb_target_group.all_target_groups.*.arn, count.index)}"
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
    target_group_arn = "${element(aws_alb_target_group.all_target_groups.*.arn, count.index)}"
  }

  condition {
    field  = "${lookup(local.lb_rules[count.index], "condition_field")}"
    values = ["${lookup(local.lb_rules[count.index], "condition_values")}"]
  }
}

variable "is_external" {
  description = "should the load balancer be external"
}

variable "target_group_prefix" {
  default     = "PROD"
  description = "A prefix added to the name of the load balancers"
}

variable "vpc_id" {
  description = "ID of the VPC"
}

variable "certificate_arn" {
  description = "ARN of the https certificate"
}

variable "security_group_ids" {
  type        = "list"
  description = "list of the sercurity group IDs"
}

variable "subnet_ids" {
  type        = "list"
  description = "list of subnet ids to associate with the load balancer"
}

variable "root_dns_zone" {
  description = "Name of root domain (ex. example.com)"
}

output "target_group_arns" {
  value = "${local.target_group_arns}"
}

output "dns_name" {
  value = "${aws_alb.alb.dns_name}"
}

output "zone_id" {
  value = "${aws_alb.alb.zone_id}"
}
