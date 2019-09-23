module "joomla_db" {
  source                   = "git@github.com:SmartColumbusOS/scos-tf-rds?ref=1.0.3"
  identifier               = "${terraform.workspace}-joomla"
  prefix                   = "${terraform.workspace}-joomla"
  database_name            = "joomla"
  type                     = "mysql"
  attached_vpc_id          = "${module.vpc.vpc_id}"
  attached_subnet_ids      = "${local.private_subnets}"
  attached_security_groups = ["${aws_security_group.chatter.id}"]
  instance_class           = "db.t2.large"
}

resource "aws_s3_bucket" "joomla-backups" {
  bucket        = "${terraform.workspace}-os-joomla-backups"
  acl           = "private"
  force_destroy = true

  lifecycle_rule {
    enabled = true

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 183
    }
  }
}
