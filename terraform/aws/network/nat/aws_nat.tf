variable "name"              { default = "nat" }
variable "region"            { }
variable "zones"             { }
variable "public_subnet_ids" { }

provider "aws" {
  region = "${var.region}"
  alias  = "${var.region}"
}

resource "aws_eip" "nat" {
  provider = "aws.${var.region}"
  # count    = "${length(split(",", var.zones))}" # Comment out count to only have 1 NAT
  vpc      = true
}

resource "aws_nat_gateway" "nat" {
  provider      = "aws.${var.region}"
  # count         = "${length(split(",", var.zones))}" # Comment out count to only have 1 NAT
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(split(",", var.public_subnet_ids), count.index)}"
}

output "nat_gateway_ids" { value = "${join(",", aws_nat_gateway.nat.*.id)}" }
