resource "aws_elb" "service" {
  subnets = ["${var.subnet_ids}"]
  security_groups = [
    "${aws_security_group.load_balancer.id}"
  ]

  internal = "${var.expose_to_public_internet == "yes" ? false : true}"

  cross_zone_load_balancing = true
  idle_timeout = "${var.idle_timeout}"
  connection_draining = true
  connection_draining_timeout = 60

  // listener {
  //   instance_port = "${var.service_port}"
  //   instance_protocol = "http"
  //   lb_port = 443
  //   lb_protocol = "https"
  //   ssl_certificate_id = "${var.service_certificate_arn}"
  // }

  listener {
   instance_port     = "${var.service_port}"
   instance_protocol = "http"
   lb_port           = 80
   lb_protocol       = "http"
 }

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 3
    timeout = 15
    target = "${var.health_check_target}"
    interval = 120
  }

  tags {
    Name = "elb-${var.component}-${var.deployment_identifier}"
    Component = "${var.component}"
    DeploymentIdentifier = "${var.deployment_identifier}"
    Service = "${var.service_name}"
  }
}
