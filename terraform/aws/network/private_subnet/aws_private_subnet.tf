variable "name"            { default = "private"}
variable "region"          { }
variable "vpc_id"          { }
variable "cidrs"           { }
variable "zones"           { }
variable "nat_gateway_ids" { }

provider "aws" {
  region = "${var.region}"
  alias  = "${var.region}"
}

resource "aws_subnet" "private" {
  provider          = "aws.${var.region}"
  count             = "${length(split(",", var.cidrs))}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(split(",", var.cidrs), count.index)}"
  availability_zone = "${element(split(",", var.zones), count.index)}"

  tags      { Name = "${var.name}.${element(split(",", var.zones), count.index)}" }
}

resource "aws_route_table" "private" {
  provider = "aws.${var.region}"
  count    = "${length(split(",", var.cidrs))}"
  vpc_id   = "${var.vpc_id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(split(",", var.nat_gateway_ids), count.index)}"
  }

  tags      { Name = "${var.name}.${element(split(",", var.zones), count.index)}" }
}

resource "aws_route_table_association" "private" {
  provider       = "aws.${var.region}"
  count          = "${length(split(",", var.cidrs))}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

output "subnet_ids" { value = "${join(",", aws_subnet.private.*.id)}" }
