resource "aws_instance" "joomla" {
  instance_type        = "m4.2xlarge"
  ami                  = "${var.joomla_backup_ami}"
  subnet_id            = "${data.aws_subnet.subnet.1.id}"
  ebs_optimized        = true
  iam_instance_profile = "CloudWatch_EC2"

  tags {
    Name    = "Joomla"
    BaseAMI = "${var.joomla_backup_ami}"
  }
}

variable "joomla_backup_ami" {
  description = "AMI to restore joomla from"

  default = "ami-95d4c6ef"
}
