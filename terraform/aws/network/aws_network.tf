variable "name"            { }
variable "region"          { }
variable "cidr"            { }
variable "zones"           { }
variable "private_subnets" { }
variable "public_subnets"  { }

module "vpc" {
  source = "./vpc"

  name   = "${var.name}-vpc"
  region = "${var.region}"
  cidr   = "${var.cidr}"
}

module "public_subnet" {
  source = "./public_subnet"

  name   = "${var.name}-public"
  region = "${var.region}"
  vpc_id = "${module.vpc.vpc_id}"
  cidrs  = "${var.public_subnets}"
  zones  = "${var.zones}"
}

module "nat" {
  source = "./nat"

  name              = "${var.name}-nat"
  region            = "${var.region}"
  zones             = "${var.zones}"
  public_subnet_ids = "${module.public_subnet.subnet_ids}"
}

module "private_subnet" {
  source = "./private_subnet"

  name            = "${var.name}-private"
  region          = "${var.region}"
  vpc_id          = "${module.vpc.vpc_id}"
  cidrs           = "${var.private_subnets}"
  zones           = "${var.zones}"
  nat_gateway_ids = "${module.nat.nat_gateway_ids}"
}

output "vpc_id"             { value = "${module.vpc.vpc_id}" }
output "vpc_cidr"           { value = "${module.vpc.vpc_cidr}" }
output "public_subnet_ids"  { value = "${module.public_subnet.subnet_ids}" }
output "private_subnet_ids" { value = "${module.private_subnet.subnet_ids}" }
output "nat_gateway_ids"    { value = "${module.nat.nat_gateway_ids}" }
