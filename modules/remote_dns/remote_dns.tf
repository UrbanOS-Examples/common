variable "remote_workspace" {
  description = "Remote workspace name"
}

variable "remote_bucket_name" {
  description = "Bucket name that the remote state is stored on"
}

variable "remote_region" {
  description = "Region to get terraform state from."
}

variable "remote_role_arn" {
  description = "Role arn to assume to retrieve terraform state."
}

variable "public_hosted_zone_id" {
  description = "Zone id of the public hosted zone"
}

variable "count" {
  description = "1 or 0, indicating whether the resource will be created or not"
}

variable "key" {
  description = "Path to the state file inside the bucket"
}

data "terraform_remote_state" "env_remote_state" {
  backend   = "s3"
  workspace = "${var.remote_workspace}"

  config {
    bucket   = "${var.remote_bucket_name}"
    key      = "${var.key}"
    region   = "${var.remote_region}"
    role_arn = "${var.remote_role_arn}"
    encrypt  = true
  }
}

resource "aws_route53_record" "env" {
  zone_id = "${var.public_hosted_zone_id}"
  name    = "${var.remote_workspace}"
  type    = "NS"
  records = ["${data.terraform_remote_state.env_remote_state.name_servers}"]
  ttl     = 300
  count   = "${var.count}"
}
