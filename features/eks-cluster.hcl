module "eks-cluster" {
  source = "github.com/SmartColumbusOS/terraform-aws-eks?ref=1.6.0"

  cluster_name    = "${local.kubernetes_cluster_name}"
  cluster_version = "${var.cluster_version}"
  ami_version     = "${var.eks_ami_version}"
  subnets         = "${local.private_subnets}"
  vpc_id          = "${module.vpc.vpc_id}"

  kubeconfig_aws_authenticator_command         = "aws-iam-authenticator"
  kubeconfig_aws_authenticator_additional_args = ["-r", "${var.role_arn}"]

  worker_additional_security_group_ids = ["${aws_security_group.chatter.id}", "${aws_security_group.allow_ssh_from_alm.id}"]

  # THIS COUNT NEEDS TO MATCH THE LENGTH OF THE PROVIDED LIST OR IT WILL NOT WORK
  # as of Terraform v0.11.7, computing this value is not seemingly supported
  worker_group_count = 5

  worker_groups = [
    {
      name               = "Workers"
      asg_min_size       = "${var.min_num_of_workers}"
      asg_max_size       = "${var.max_num_of_workers}"
      instance_type      = "${var.k8s_instance_size}"
      key_name           = "${aws_key_pair.cloud_key.key_name}"
      kubelet_extra_args = "${var.kubelet_security_args}"
      pre_userdata       = "${file("${path.module}/files/eks/workers_pre_userdata")}"
    },
    {
      name               = "Worker-Group-Two-Workers"
      asg_min_size       = "0"
      asg_max_size       = "0"
      instance_type      = "t2.medium"
      key_name           = "${aws_key_pair.cloud_key.key_name}"
      kubelet_extra_args = "--register-with-taints=scos.run.group-two=true:NoExecute --node-labels=scos.run.group-two=true ${var.kubelet_security_args}"
      pre_userdata       = "${file("${path.module}/files/eks/workers_pre_userdata")}"
    },
    {
      name               = "Kafka-Workers"
      asg_min_size       = "${var.min_num_of_kafka_workers}"
      asg_max_size       = "${var.max_num_of_kafka_workers}"
      instance_type      = "${var.kafka_worker_instance_size}"
      key_name           = "${aws_key_pair.cloud_key.key_name}"
      kubelet_extra_args = "--register-with-taints=scos.run.kafka=true:NoExecute --node-labels=scos.run.kafka=true ${var.kubelet_security_args}"
      pre_userdata       = "${file("${path.module}/files/eks/workers_pre_userdata")}"
    },
    {
      # so we don't have to go through a roll in the future - set to zeros and something inconsequential until we figure out what we need
      name               = "Memory-Optimized-Workers"
      asg_min_size       = "0"
      asg_max_size       = "0"
      instance_type      = "r5a.large"
      key_name           = "${aws_key_pair.cloud_key.key_name}"
      kubelet_extra_args = "--node-labels=scos.run.memory-optimized=true ${var.kubelet_security_args}"
      pre_userdata       = "${file("${path.module}/files/eks/workers_pre_userdata")}"
    },
    {
      name               = "CPU-Optimized-Workers"
      asg_min_size       = "0"
      asg_max_size       = "0"
      instance_type      = "t2.nano"
      key_name           = "${aws_key_pair.cloud_key.key_name}"
      kubelet_extra_args = "--node-labels=scos.run.cpu-optimized=true ${var.kubelet_security_args}"
      pre_userdata       = "${file("${path.module}/files/eks/workers_pre_userdata")}"
    },
  ]

  tags = {
    Environment = "${terraform.workspace}"
  }
}

resource "aws_security_group" "allow_ssh_from_alm" {
  name_prefix = "allow_ssh_from_alm_"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    # datablock from vpc_peer.tf
    cidr_blocks = ["${data.terraform_remote_state.alm_remote_state.vpc_cidr_block}"]
  }
}

resource "aws_iam_policy" "eks_work_alb_permissions" {
  name        = "eks_work_alb_permissions-${terraform.workspace}"
  description = "This policy allows EKS Worker nodes to do everything it needs to do with an ALB"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "123",
            "Effect": "Allow",
            "Action": [
                "tag:GetResources",

                "ec2:Describe*",
                "ec2:GetLaunchTemplateData",
                "ec2:GetConsoleOutput",
                "ec2:GetPasswordData",
                "ec2:GetReservedInstancesExchangeQuote",
                "ec2:GetConsoleScreenshot",
                "ec2:GetHostReservationPurchasePreview",

                "waf-regional:Get*",
                "waf-regional:List*",

                "acm:ListCertificates",
                "iam:ListServerCertificates",

                "ce:GetReservationUtilization",
                "ce:GetDimensionValues",
                "ce:GetCostAndUsage",
                "ce:GetTags",

                "elasticloadbalancing:*",

                "route53:ListHostedZones",
                "route53:ListResourceRecordSets",

                "cloudwatch:PutMetricData",
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:GetMetricData",

                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
              "route53:ChangeResourceRecordSets"
            ],
            "Resource": [
              "arn:aws:route53:::hostedzone/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
              "wafv2:GetWebACL",
              "wafv2:GetWebACLForResource",
              "wafv2:AssociateWebACL",
              "wafv2:DisassociateWebACL"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "local_file" "aws_props" {
  content = <<EOF
aws:
  publicSubnets: ${jsonencode(module.vpc.public_subnets)}
  allowWebTrafficSecurityGroup: ${aws_security_group.allow_all.id}
  certificateArn: "${module.tls_certificate.arn}"
EOF

  filename = "${path.module}/aws.yaml"
}

resource "null_resource" "eks_infrastructure" {
  depends_on = ["data.external.helm_file_change_check", "local_file.aws_props"]

  provisioner "local-exec" {
    command = <<EOF
set -e
export KUBECONFIG=${path.module}/kubeconfig_streaming-kube-${terraform.workspace}
kubectl apply -f ${path.module}/k8s/tiller-role/
kubectl patch sc gp2 --patch "$(cat ${path.module}/k8s/storage-class/patch-not-default.yaml)"
helm init --service-account tiller

LOOP_COUNT=10
for i in $(seq 1 $LOOP_COUNT); do
    [ $i -gt 1 ] && sleep 15
    [ $(kubectl get pods --namespace kube-system -l name='tiller' | grep -i Running | grep -ic '1/1') -gt 0 ] && break
    echo "Running Tiller Pod not found"
    [ $i -eq $LOOP_COUNT ] && exit 1
done
echo "Identified Running Tiller Pod..."

# label the dns namespace to later select for network policy rules; overwrite = no-op
kubectl get namespaces | egrep '^cluster-infra ' || kubectl create namespace cluster-infra
kubectl label namespace cluster-infra name=cluster-infra --overwrite

cd ${path.module}/helm/cluster-infra
helm dependency update
cd -

helm upgrade --install cluster-infra ${path.module}/helm/cluster-infra \
    --namespace=cluster-infra \
    --set externalDns.args."domain\-filter"="{${aws_route53_zone.internal_public_hosted_zone.name},${aws_route53_zone.root_public_hosted_zone.name}}" \
    --set albIngress.extraEnv."AWS\_REGION"="${var.region}" \
    --set albIngress.extraEnv."CLUSTER\_NAME"="${module.eks-cluster.cluster_id}" \
    --values ${path.module}/helm/cluster-infra/run-config.yaml \
    --values ${local_file.aws_props.filename}

EOF
  }

  triggers {
    helm_file_change_check = "${data.external.helm_file_change_check.result.md5_result}"
    aws_props              = "${local_file.aws_props.content}"
  }
}

resource "null_resource" "tear_down_load_balancers" {
  provisioner "local-exec" {
    when = "destroy"

    command = <<EOF
    set -e
    echo "Destroying load balancers..."
    ${path.module}/files/scripts/destroy_albs_created_via_kubernetes.sh ${module.vpc.vpc_id} ${var.region} ${var.role_arn}
  EOF
  }
}

data "external" "helm_file_change_check" {
  program = [
    "${path.module}/files/scripts/helm_file_change_check.sh",
    "${path.module}/helm/cluster-infra",
  ]
}

resource "aws_iam_role_policy_attachment" "eks_work_alb_permissions" {
  role       = "${module.eks-cluster.worker_iam_role_name}"
  policy_arn = "${aws_iam_policy.eks_work_alb_permissions.arn}"
}

resource "aws_wafv2_web_acl" "eks_cluster" {
  name        = "eks-cluster-web-acl-${terraform.workspace}"
  description = "WAFv2 Web ACL available to all EKS based ALBs"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesAdminProtectionRuleSet"
    priority = 0

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAdminProtectionRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAdminProtectionRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesLinuxRuleSet"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesLinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesPHPRuleSet"
    priority = 5

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesPHPRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesPHPRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "AWS-AWSWebACLEKSCluster"
    sampled_requests_enabled   = false
  }
}

data "aws_eks_cluster" "eks_cluster" {
  name = "${module.eks-cluster.cluster_id}"
}

data "external" "oidc_thumbprint" {
  program = ["${path.module}/files/scripts/oidc_thumbprint.sh", "${var.region}"]
}

resource "aws_iam_openid_connect_provider" "eks_cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["${data.external.oidc_thumbprint.result.thumbprint}"]
  url             = "${data.aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer}"
}

variable "cluster_version" {
  description = "The version of k8s at which to install the cluster"
  default     = "1.15"
}

variable "eks_ami_version" {
  description = "the version of the EKS AMI to use to deploy workers"
  default     = "20200406"
}

variable "k8s_instance_size" {
  # See Note below on changing instance type
  description = "EC2 instance type"
  default     = "t2.xlarge"
}

variable "kafka_worker_instance_size" {
  # See Note below on changing instance type
  description = "EC2 instance type for kafka workers"
  default     = "r5a.large"
}

# If you're changing ec2 instance types to a newer generation of server you may need to update the CNI plugin.
# https://docs.aws.amazon.com/en_us/eks/latest/userguide/cni-upgrades.html
# kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.5/config/v1.5/aws-k8s-cni.yaml

variable "min_num_of_workers" {
  description = "Minimum number of workers to be created on eks cluster"
  default     = 6
}

variable "max_num_of_workers" {
  description = "Maximum number of workers to be created on eks cluster"
  default     = 12
}

variable "min_num_of_kafka_workers" {
  description = "Minimum number of kafka workers to be created on eks cluster"
  default     = 3
}

variable "max_num_of_kafka_workers" {
  description = "Maximum number of kafka workers to be created on eks cluster"
  default     = 5
}

variable "kubelet_security_args" {
  description = "A set of additional kubelet configurations to meet security standards. WARNING: Invalid command line parameters here will cause all nodes deployed with these settings to never become ready. This kills the cluster."
  default     = "--read-only-port=0 --event-qps=0"
}

output "eks_cluster_kubeconfig" {
  description = "Working kubeconfig to talk to the eks cluster."
  value       = "${module.eks-cluster.kubeconfig}"
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = "${local.kubernetes_cluster_name}"
}

output "eks_worker_role_arn" {
  description = "EKS Worker Role ARN"
  value       = "${module.eks-cluster.worker_iam_role_arn}"
}

output "eks_cluster_oidc_provider_url" {
  description = "The OpendId Connect provider URL for the cluster"
  value       = "${aws_iam_openid_connect_provider.eks_cluster.url}"
}

output "eks_cluster_oidc_provider_host" {
  description = "The OpendId Connect provider host for the cluster"
  value       = "${replace(aws_iam_openid_connect_provider.eks_cluster.url, "https://", "")}"
}

output "eks_cluster_oidc_provider_arn" {
  description = "The OpendId Connect provider ARN for the cluster"
  value       = "${aws_iam_openid_connect_provider.eks_cluster.arn}"
}

output "eks_cluster_waf_acl_arn" {
  description = "The ARN for the EKS cluster's WAFv2 ACL ARN"
  value       = "${aws_wafv2_web_acl.eks_cluster.arn}"
}
