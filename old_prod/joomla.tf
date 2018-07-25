data "template_file" "joomla_unite_config" {
  template = "${file("${path.module}/templates/joomla_unite_config.xml.tpl")}"

  vars {
    S3_FILE_NAME       = "${var.joomla_backup_file_name}"
    S3_ACCESS_KEY      = "${var.s3_readonly_access_key}"
    S3_SECRET_KEY      = "${var.s3_readonly_secret_key}"
    JOOMLA_ADMIN_EMAIL = "smartcolumbusos@columbus.gov"
    JOOMLA_SITE_URL    = "https://www.smartcolumbusos.com/"
    JOOMLA_DB_HOST     = "${aws_db_instance.joomla_db.address}"
    JOOMLA_DB_USER     = "${aws_db_instance.joomla_db.username}"
    JOOMLA_DB_PASSWORD = "${var.joomla_db_password}"
  }
}

resource "aws_instance" "joomla" {
  instance_type        = "${var.joomla_instance_type}"
  ami                  = "${var.joomla_backup_ami}"
  security_groups      = ["${data.aws_security_group.scos_servers.id}"]
  ebs_optimized        = "${var.joomla_instance_ebs_optimized}"
  iam_instance_profile = "${var.joomla_instance_profile}"
  subnet_id            = "${data.aws_subnet.subnet.1.id}"

  tags {
    Name    = "Joomla"
    BaseAMI = "${var.joomla_backup_ami}"
  }

  provisioner "file" {
    content     = "${data.template_file.joomla_unite_config.rendered}"
    destination = "/opt/scos_unite.xml"

    connection {
      type = "ssh"
      host = "${aws_instance.joomla.private_ip}"
      user = "centos"
    }
  }

  provisioner "file" {
    source      = "${path.module}/files/unite.phar"
    destination = "/opt/unite.phar"
  }

  provisioner "remote-exec" {
    inline = [
      "php /opt/unite.phar /opt/scos_unite.xml --debug",
    ]
  }
}

resource "aws_db_instance" "joomla_db" {
  identifier             = "${terraform.workspace}-joomla"
  instance_class         = "db.t2.large"
  vpc_security_group_ids = ["${data.aws_security_group.scos_servers.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.default.name}"
  skip_final_snapshot    = true
  engine                 = "mysql"
  engine_version         = "5.6.37"
  parameter_group_name   = "default.mysql5.6"
  allocated_storage      = 100
  storage_type           = "gp2"
  username               = "joomla_prod"
  password               = "${var.joomla_db_password}"

  tags {
    workload-type = "other"
  }
}

variable "joomla_instance_ebs_optimized" {
  description = "Whether or not the Joomla server is EBS optimized"
  default     = true
}

variable "joomla_instance_profile" {
  description = "Instance Profile for Joomla server"
  default     = "CloudWatch_EC2"
}

variable "joomla_instance_type" {
  description = "Instance type for Joomla server"
  default     = "m4.2xlarge"
}

variable "joomla_backup_ami" {
  description = "AMI to restore Joomla from"

  default = "ami-95d4c6ef"
}

variable "s3_readonly_access_key" {
  description = "Access Key for S3 read only user"
}

variable "s3_readonly_secret_key" {
  description = "Secret Key for S3 read only user"
}

variable "joomla_backup_file_name" {
  description = "Name of the Akeeba backup file in the backup S3 bucket"
}

variable "joomla_db_password" {
  description = "Password for joomla database"
}
