variable "name"              { }
variable "atlas_username"    { }
variable "atlas_environment" { }
variable "atlas_token"       { }
variable "region"            { }
variable "vpc_id"            { }
variable "vpc_cidr"          { }
variable "subnet_ids"        { }
variable "zones"             { }
variable "node_classes"      { }
variable "consul_log_level"  { }
variable "nomad_log_level"   { }
variable "key_name"          { }
variable "private_key"       { }

variable "utility_image"   { }
variable "utility_machine" { }
variable "utility_disk"    { }

variable "consul_server_image"   { }
variable "consul_server_machine" { }
variable "consul_server_disk"    { }
variable "consul_servers"        { }

variable "nomad_server_image"   { }
variable "nomad_server_machine" { }
variable "nomad_server_disk"    { }
variable "nomad_servers"        { }

variable "nomad_client_image"   { }
variable "nomad_client_machine" { }
variable "nomad_client_disk"    { }
variable "nomad_client_groups"  { }
variable "nomad_clients"        { }

module "utility" {
  source = "./utility"

  name              = "${var.name}-utility"
  atlas_username    = "${var.atlas_username}"
  atlas_environment = "${var.atlas_environment}"
  atlas_token       = "${var.atlas_token}"
  region            = "${var.region}"
  vpc_id            = "${var.vpc_id}"
  vpc_cidr          = "${var.vpc_cidr}"
  subnet_ids        = "${var.subnet_ids}"
  zones             = "${var.zones}"
  image             = "${var.utility_image}"
  machine_type      = "${var.utility_machine}"
  disk_size         = "${var.utility_disk}"
  consul_log_level  = "${var.consul_log_level}"
  key_name          = "${var.key_name}"
  private_key       = "${var.private_key}"
}

module "consul_servers" {
  source = "./consul_server"

  name              = "${var.name}-consul-server"
  atlas_username    = "${var.atlas_username}"
  atlas_environment = "${var.atlas_environment}"
  atlas_token       = "${var.atlas_token}"
  region            = "${var.region}"
  vpc_id            = "${var.vpc_id}"
  vpc_cidr          = "${var.vpc_cidr}"
  subnet_ids        = "${var.subnet_ids}"
  zones             = "${var.zones}"
  image             = "${var.consul_server_image}"
  machine_type      = "${var.consul_server_machine}"
  disk_size         = "${var.consul_server_disk}"
  servers           = "${var.consul_servers}"
  consul_log_level  = "${var.consul_log_level}"
  key_name          = "${var.key_name}"
  private_key       = "${var.private_key}"
}

module "nomad_servers" {
  source = "./nomad_server"

  name              = "${var.name}-nomad-server"
  atlas_username    = "${var.atlas_username}"
  atlas_environment = "${var.atlas_environment}"
  atlas_token       = "${var.atlas_token}"
  region            = "${var.region}"
  vpc_id            = "${var.vpc_id}"
  vpc_cidr          = "${var.vpc_cidr}"
  subnet_ids        = "${var.subnet_ids}"
  zones             = "${var.zones}"
  image             = "${var.nomad_server_image}"
  machine_type      = "${var.nomad_server_machine}"
  disk_size         = "${var.nomad_server_disk}"
  servers           = "${var.nomad_servers}"
  nomad_log_level   = "${var.nomad_log_level}"
  consul_log_level  = "${var.consul_log_level}"
  key_name          = "${var.key_name}"
  private_key       = "${var.private_key}"
}

module "nomad_clients_asg" {
  source = "./nomad_client_asg"

  name              = "${var.name}-nomad-client"
  atlas_username    = "${var.atlas_username}"
  atlas_environment = "${var.atlas_environment}"
  atlas_token       = "${var.atlas_token}"
  region            = "${var.region}"
  vpc_id            = "${var.vpc_id}"
  vpc_cidr          = "${var.vpc_cidr}"
  subnet_ids        = "${var.subnet_ids}"
  zones             = "${var.zones}"
  image             = "${var.nomad_client_image}"
  machine_type      = "${var.nomad_client_machine}"
  disk_size         = "${var.nomad_client_disk}"
  groups            = "${var.nomad_client_groups}"
  clients           = "${var.nomad_clients}"
  node_classes      = "${var.node_classes}"
  nomad_log_level   = "${var.nomad_log_level}"
  consul_log_level  = "${var.consul_log_level}"
  key_name          = "${var.key_name}"
  private_key       = "${var.private_key}"
}

output "utility_name"       { value = "${module.utility.name}" }
output "utility_private_ip" { value = "${module.utility.private_ip}" }
output "utility_public_ip"  { value = "${module.utility.public_ip}" }

output "consul_server_names"       { value = "${module.consul_servers.names}" }
output "consul_server_private_ips" { value = "${module.consul_servers.private_ips}" }
output "consul_server_public_ips"  { value = "${module.consul_servers.public_ips}" }

output "nomad_server_names"       { value = "${module.nomad_servers.names}" }
output "nomad_server_private_ips" { value = "${module.nomad_servers.private_ips}" }
output "nomad_server_public_ips"  { value = "${module.nomad_servers.public_ips}" }
