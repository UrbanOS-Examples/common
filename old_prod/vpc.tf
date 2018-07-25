data "aws_vpc" "default" {
  tags {
    Name = "${var.vpc_name}"
  }
}

data "aws_subnet" "subnet" {
  count = "${length(var.vpc_regions)}"

  vpc_id            = "${data.aws_vpc.default.id}"
  availability_zone = "${var.vpc_regions[count.index]}"
}

data "aws_security_group" "scos_servers" {
  name   = "SCOS Servers"
  vpc_id = "${data.aws_vpc.default.id}"
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = ["${data.aws_subnet.subnet.*.id}"]

  tags {
    Name = "Default Subnet Group"
  }
}

variable "vpc_name" {
  description = "Name of the VPC to search for when importing the VPC data source"
  default     = "Prod-VPC"
}

variable "vpc_regions" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
}
