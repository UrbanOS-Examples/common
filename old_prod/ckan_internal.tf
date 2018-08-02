resource "aws_instance" "ckan_internal" {
  instance_type          = "${var.ckan_internal_instance_type}"
  ami                    = "${var.ckan_internal_backup_ami}"
  vpc_security_group_ids = ["${data.aws_security_group.scos_servers.id}"]
  ebs_optimized          = "${var.ckan_internal_instance_ebs_optimized}"
  iam_instance_profile   = "${var.ckan_internal_instance_profile}"
  subnet_id              = "${data.aws_subnet.subnet.1.id}"
  key_name               = "${var.ckan_keypair_name}"

  tags {
    Name    = "CKAN Internal"
    BaseAMI = "${var.ckan_internal_backup_ami}"
  }
}

resource "aws_db_instance" "ckan_internal" {
  identifier                = "${var.ckan_db_identifier}"
  instance_class            = "${var.ckan_db_instance_class}"
  vpc_security_group_ids    = ["${data.aws_security_group.scos_servers.id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.default.name}"
  skip_final_snapshot       = false
  engine                    = "postgres"
  engine_version            = "${var.ckan_db_engine_version}"
  parameter_group_name      = "${var.ckan_db_parameter_group_name}"
  allocated_storage         = "${var.ckan_db_allocated_storage}"
  storage_type              = "gp2"
  username                  = "sysadmin"
  password                  = "${var.ckan_db_password}"
  snapshot_identifier       = "${var.ckan_rds_snapshot_id}"
  final_snapshot_identifier = "ckan-${sha1(timestamp())}"
  multi_az                  = "${var.rds_multi_az}"
  storage_encrypted         = "${var.ckan_db_storage_encrypted}"

  lifecycle {
    ignore_changes = ["snapshot_identifier"]
  }

  tags {
    workload-type = "other"
  }
}

resource "aws_route53_record" "ckan_internal_ec2_record" {
  zone_id = "${aws_route53_zone.private_hosted_zone.zone_id}"
  name    = "ckan-internal"
  type    = "A"
  count   = 1
  ttl     = 300

  records = ["${aws_instance.ckan_internal.private_ip}"]
}

resource "aws_route53_record" "ckan_internal_db_record" {
  zone_id = "${aws_route53_zone.private_hosted_zone.zone_id}"
  name    = "db.ckan"
  type    = "CNAME"
  count   = 1
  ttl     = 300

  records = ["${aws_db_instance.ckan_internal.address}"]
}

variable "ckan_rds_snapshot_id" {
  description = "The id of the ckan RDS snapshot to restore"
}

variable "ckan_internal_instance_ebs_optimized" {
  description = "Whether or not the CKAN internal server is EBS optimized"
  default     = true
}

variable "ckan_db_instance_class" {
  description = "The type of the instance for the ckan database"
}

variable "ckan_db_allocated_storage" {
  description = "The size of the ckan database in GB"
}

variable "ckan_db_parameter_group_name" {
  description = "The identifier for the db parameter group for a version of postgres"
}

variable "ckan_db_engine_version" {
  description = "The version of postgresql used for ckan"
}

variable "ckan_internal_instance_profile" {
  description = "Instance Profile for ckan_internal server"
  default     = "CloudWatch_EC2"
}

variable "ckan_internal_instance_type" {
  description = "Instance type for ckan_internal server"
  default     = "m4.2xlarge"
}

variable "ckan_internal_backup_ami" {
  description = "AMI to restore ckan_internal from"
}

variable "ckan_db_password" {
  description = "Password for ckan_internal database"
}

variable "ckan_db_identifier" {
  description = "AWS RDS identifier for ckan_internal db instance"
}

variable "ckan_db_storage_encrypted" {
  description = "Is ckan db encrypted"
}
