module "eks-cluster" {
  source = "github.com/SmartColumbusOS/terraform-aws-eks?ref=1.6.0"

  cluster_name    = "${local.kubernetes_cluster_name}"
  cluster_version = "${var.cluster_version}"
  ami_version     = "${var.eks_ami_version}"
  subnets         = "${local.private_subnets}"
  vpc_id          = "${module.vpc.vpc_id}"

  kubeconfig_aws_authenticator_command         = "heptio-authenticator-aws"
  kubeconfig_aws_authenticator_additional_args = ["-r", "${var.role_arn}"]

  worker_additional_security_group_ids = ["${aws_security_group.chatter.id}", "${aws_security_group.allow_ssh_from_alm.id}"]

  # THIS COUNT NEEDS TO MATCH THE LENGTH OF THE PROVIDED LIST OR IT WILL NOT WORK
  # as of Terraform v0.11.7, computing this value is not seemingly supported
  worker_group_count = 2
  worker_groups = [
    {
      name                 = "Workers"
      asg_min_size         = "${var.min_num_of_workers}"
      asg_max_size         = "${var.max_num_of_workers}"
      instance_type        = "${var.k8s_instance_size}"
      key_name             = "${aws_key_pair.cloud_key.key_name}"
      pre_userdata         = "${file("${path.module}/files/eks/workers_pre_userdata")}"
    },
    {
      name                 = "Jupyterhub-Workers"
      asg_min_size         = "${var.min_num_of_jupyterhub_workers}"
      asg_max_size         = "${var.max_num_of_jupyterhub_workers}"
      instance_type        = "t2.medium"
      key_name             = "${aws_key_pair.cloud_key.key_name}"
      kubelet_extra_args   = "--register-with-taints=scos.run.jupyterhub=true:NoExecute --node-labels=scos.run.jupyterhub=true"
      pre_userdata         = "${file("${path.module}/files/eks/workers_pre_userdata")}"
    },
  ]

  tags = {
    Environment = "${terraform.workspace}"
  }
}

resource "aws_security_group" "allow_ssh_from_alm" {
  name_prefix = "allow_ssh_from_alm_"
  vpc_id       = "${module.vpc.vpc_id}"

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
    aws_props = "${local_file.aws_props.content}"
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
    "${path.module}/helm/cluster-infra"
    ]
}

resource "aws_iam_role_policy_attachment" "eks_work_alb_permissions" {
  role       = "${module.eks-cluster.worker_iam_role_name}"
  policy_arn = "${aws_iam_policy.eks_work_alb_permissions.arn}"
}

variable "cluster_version" {
  description = "The version of k8s at which to install the cluster"
  default     = "1.10"
}

variable "eks_ami_version" {
  description = "the version of the EKS AMI to use to deploy workers"
  default     = "20181210"
}

variable "k8s_instance_size" {
  description = "EC2 instance type"
  default = "t2.xlarge"
}

variable "min_num_of_workers" {
  description = "Minimum number of workers to be created on eks cluster"
  default = 6
}

variable "max_num_of_workers" {
  description = "Maximum number of workers to be created on eks cluster"
  default = 12
}

variable "min_num_of_jupyterhub_workers" {
  description = "Minimum number of JupyterHub workers to be created on eks cluster"
  default = 3
}

variable "max_num_of_jupyterhub_workers" {
  description = "Maximum number of JupyterHub workers to be created on eks cluster"
  default = 5
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
  value = "${module.eks-cluster.worker_iam_role_arn}"
}