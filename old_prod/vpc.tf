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

variable "vpc_name" {
  description = "Name of the VPC to search for when importing the VPC data source"
  default     = "Prod-VPC"
}

variable "vpc_regions" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
}
