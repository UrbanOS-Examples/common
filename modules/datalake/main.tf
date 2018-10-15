data "aws_subnet" "az_selector" {
  id = "${local.cluster_subnet}"
}

resource "random_shuffle" "private_subnet" {
  input = ["${var.subnets}"]

  keepers = {
    private_subnets = "${join(",", var.subnets)}"
  }
}
