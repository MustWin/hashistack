variable "name"              { }
variable "project_id"        { }
variable "credentials"       { }
variable "region"            { }
variable "network"           { }
variable "zones"             { }
variable "node_classes"      { }
variable "consul_log_level"  { }
variable "nomad_log_level"   { }

variable "ssh_keys"  { }
variable "private_key"  { }

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


module "consul_servers" {
  source = "./consul_server"

  name              = "${var.name}-consul-server"
  project_id        = "${var.project_id}"
  credentials       = "${var.credentials}"
  region            = "${var.region}"
  network           = "${var.network}"
  zones             = "${var.zones}"
  image             = "${var.consul_server_image}"
  machine_type      = "${var.consul_server_machine}"
  disk_size         = "${var.consul_server_disk}"
  servers           = "${var.consul_servers}"
  consul_log_level  = "${var.consul_log_level}"
  ssh_keys          = "${var.ssh_keys}"
  private_key       = "${var.private_key}"
}


module "utility" {
  source = "./utility"

  name              = "${var.name}-utility"
  project_id        = "${var.project_id}"
  credentials       = "${var.credentials}"
  region            = "${var.region}"
  network           = "${var.network}"
  zones             = "${var.zones}"
  image             = "${var.utility_image}"
  machine_type      = "${var.utility_machine}"
  disk_size         = "${var.utility_disk}"
  consul_log_level  = "${var.consul_log_level}"
  ssh_keys        = "${var.ssh_keys}"
  private_key     = "${var.private_key}"
  consul_servers  = "${module.consul_servers.private_ips}"
}



module "nomad_servers" {
  source = "./nomad_server"

  name              = "${var.name}-nomad-server"
  project_id        = "${var.project_id}"
  credentials       = "${var.credentials}"
  region            = "${var.region}"
  network           = "${var.network}"
  zones             = "${var.zones}"
  image             = "${var.nomad_server_image}"
  machine_type      = "${var.nomad_server_machine}"
  disk_size         = "${var.nomad_server_disk}"
  servers           = "${var.nomad_servers}"
  nomad_log_level   = "${var.nomad_log_level}"
  consul_log_level  = "${var.consul_log_level}"
  ssh_keys        = "${var.ssh_keys}"
  private_key     = "${var.private_key}"
  consul_servers  = "${module.consul_servers.private_ips}"
}
/* // Raw Nodes
module "nomad_client" {
  source = "./nomad_client"

  name              = "${var.name}-nomad-client"
  project_id        = "${var.project_id}"
  credentials       = "${var.credentials}"
  region            = "${var.region}"
  network           = "${var.network}"
  zones             = "${var.zones}"
  image             = "${var.nomad_client_image}"
  machine_type      = "${var.nomad_client_machine}"
  disk_size         = "${var.nomad_client_disk}"
  #groups            = "${var.nomad_client_groups}"
  nomad_clients     = "${var.nomad_clients}"
  node_classes      = "${var.node_classes}"
  nomad_log_level   = "${var.nomad_log_level}"
  consul_log_level  = "${var.consul_log_level}"
  ssh_keys        = "${var.ssh_keys}"
  private_key     = "${var.private_key}"
  consul_servers  = "${module.consul_servers.private_ips}"
}
*/

// IGM Nodes
module "nomad_clients_igm" {
  source = "./nomad_client_igm"

  name              = "${var.name}-nomad-client"
  project_id        = "${var.project_id}"
  credentials       = "${var.credentials}"
  region            = "${var.region}"
  network           = "${var.network}"
  zones             = "${var.zones}"
  image             = "${var.nomad_client_image}"
  machine_type      = "${var.nomad_client_machine}"
  disk_size         = "${var.nomad_client_disk}"
  groups            = "${var.nomad_client_groups}"
  nomad_clients     = "${var.nomad_clients}"
  node_classes      = "${var.node_classes}"
  nomad_log_level   = "${var.nomad_log_level}"
  consul_log_level  = "${var.consul_log_level}"
  ssh_keys          = "${var.ssh_keys}"
  private_key       = "${var.private_key}"
  consul_servers    = "${module.consul_servers.private_ips}"
}

output "utility_name"         { value = "${module.utility.name}" }
output "utility_machine_type" { value = "${module.utility.machine_type}" }
output "utility_private_ip"   { value = "${module.utility.private_ip}" }
output "utility_public_ip"    { value = "${module.utility.public_ip}" }

output "consul_server_names"         { value = "${module.consul_servers.names}" }
output "consul_server_machine_types" { value = "${module.consul_servers.machine_types}" }
output "consul_server_private_ips"   { value = "${module.consul_servers.private_ips}" }
output "consul_server_public_ips"    { value = "${module.consul_servers.public_ips}" }

output "nomad_server_names"         { value = "${module.nomad_servers.names}" }
output "nomad_server_machine_types" { value = "${module.nomad_servers.machine_types}" }
output "nomad_server_private_ips"   { value = "${module.nomad_servers.private_ips}" }
output "nomad_server_public_ips"    { value = "${module.nomad_servers.public_ips}" }
