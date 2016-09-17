variable "name"   { default = "vpc" }
variable "region" { }
variable "cidr"   { }

provider "aws" {
  region = "${var.region}"
  alias  = "${var.region}"
}

resource "aws_vpc" "vpc" {
  provider             = "aws.${var.region}"
  cidr_block           = "${var.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags { Name = "${var.name}" }
}

output "vpc_id"   { value = "${aws_vpc.vpc.id}" }
output "vpc_cidr" { value = "${aws_vpc.vpc.cidr_block}" }
