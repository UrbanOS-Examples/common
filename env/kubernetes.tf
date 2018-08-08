module "kubernetes" {
  source              = "github.com/SmartColumbusOS/terraform-aws-kubernetes"
  cluster_name        = "${local.kubernetes_cluster_name}"
  aws_region          = "${var.region}"
  hosted_zone         = "${aws_route53_zone.private.name}"
  hosted_zone_id      = "${aws_route53_zone.private.zone_id}"
  hosted_zone_private = true
  master_subnet_id    = "${module.vpc.private_subnets[0]}"
  worker_subnet_ids   = "${module.vpc.private_subnets}"
  min_worker_count    = "${var.min_worker_count}"
  max_worker_count    = "${var.max_worker_count}"
  ssh_public_key      = "${var.kube_key}"

  addons = [
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/storage-class.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/heapster.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/dashboard.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/external-dns.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/autoscaler.yaml",
  ]

  tags = {
    Environmnet = "${terraform.workspace}"
    DNSZone     = "${aws_route53_zone.private.zone_id}"
  }

  tags2 = [
    {
      key                 = "Application"
      value               = "AWS-Kubernetes"
      propagate_at_launch = true
    },
  ]
}

variable "min_worker_count" {
  description = "Minimum kubernetes workers"
  default     = 5
}

variable "max_worker_count" {
  description = "Maximum kubernetes worker"
  default     = 5
}

variable "kube_key" {
  description = "The SSH key to use for kubernetes hosts"
  default     = "./k8_rsa.pub"
}

output "kubernetes_master_private_ip" {
  description = "The private IP of the kubernetes master"
  value       = "${module.kubernetes.private_ip}"
}
