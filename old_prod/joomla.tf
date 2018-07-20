resource "aws_instance" "joomla" {
  instance_type = "m4.2xlarge"
  ami           = "${var.joomla_backup_ami}"

  ebs_optimized        = true
  iam_instance_profile = "CloudWatch_EC2"

  tags {
    Name    = "Joomla"
    BaseAMI = "${var.joomla_backup_ami}"
  }

  provisioner "remote-exec" {
    inline = [
      "ls /",
    ]
  }
}

resource "aws_db_instance" "joomla_db" {
  instance_class       = "db.t2.large"
  skip_final_snapshot  = true
  engine               = "mysql"
  engine_version       = "5.6.37"
  parameter_group_name = "default.mysql5.6"
  allocated_storage    = 100
  storage_type         = "gp2"

  tags {
    workload-type = "other"
  }
}

variable "joomla_backup_ami" {
  description = "AMI to restore joomla from"

  default = "ami-95d4c6ef"
}
