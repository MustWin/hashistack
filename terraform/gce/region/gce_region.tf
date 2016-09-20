variable "name"              { }
variable "project_id"        { }
variable "credentials"  { }

variable "region"      { }
variable "cidr"        { }
variable "zones"       { }
variable "ssh_keys" { }
variable "private_key" { }

variable "artifact_type"    { default = "google.image" }
variable "consul_log_level" { }
variable "nomad_log_level"  { }
variable "node_classes"     { }
variable "artifact_prefix"  { default = "packer" }

variable "utility_artifact_name"    { }
variable "utility_artifact_version" { default = "latest" }
variable "utility_machine"          { }
variable "utility_disk"             { }

variable "consul_server_artifact_name"    { }
variable "consul_server_artifact_version" { default = "latest" }
variable "consul_server_machine"          { }
variable "consul_server_disk"             { }
variable "consul_servers"                 { }

variable "nomad_server_artifact_name"    { }
variable "nomad_server_artifact_version" { default = "latest" }
variable "nomad_server_machine"          { }
variable "nomad_server_disk"             { }
variable "nomad_servers"                 { }

variable "nomad_client_artifact_name"    { }
variable "nomad_client_artifact_version" { default = "latest" }
variable "nomad_client_machine"          { }
variable "nomad_client_disk"             { }
variable "nomad_client_groups"           { }
variable "nomad_clients"                 { }

provider "google" {
  region      = "${var.region}"
  alias       = "${var.region}"
  project     = "${var.project_id}"
  credentials = "${var.credentials}"
}

module "network" {
  source = "../network"

  name = "${var.name}"
  cidr = "${var.cidr}"
}

module "compute" {
  source = "../compute"

  name              = "${var.name}"
  project_id        = "${var.project_id}"
  credentials       = "${var.credentials}"
  region            = "${var.region}"
  network           = "${module.network.name}"
  zones             = "${var.zones}"
  node_classes      = "${var.node_classes}"
  consul_log_level  = "${var.consul_log_level}"
  nomad_log_level   = "${var.nomad_log_level}"
  ssh_keys          = "${var.ssh_keys}"
  private_key       = "${var.private_key}"

  utility_image   = "${var.artifact_prefix}-${var.utility_artifact_name}-${var.utility_artifact_version}"
  utility_machine = "${var.utility_machine}"
  utility_disk    = "${var.utility_disk}"

  consul_server_image   = "${var.artifact_prefix}-${var.consul_server_artifact_name}-${var.consul_server_artifact_version}"
  consul_server_machine = "${var.consul_server_machine}"
  consul_server_disk    = "${var.consul_server_disk}"
  consul_servers        = "${var.consul_servers}"

  nomad_server_image   = "${var.artifact_prefix}-${var.nomad_server_artifact_name}-${var.nomad_server_artifact_version}"
  nomad_server_machine = "${var.nomad_server_machine}"
  nomad_server_disk    = "${var.nomad_server_disk}"
  nomad_servers        = "${var.nomad_servers}"

  nomad_client_image   = "${var.artifact_prefix}-${var.nomad_client_artifact_name}-${var.nomad_client_artifact_version}"
  nomad_client_machine = "${var.nomad_client_machine}"
  nomad_client_disk    = "${var.nomad_client_disk}"
  nomad_client_groups  = "${var.nomad_client_groups}"
  nomad_clients        = "${var.nomad_clients}"
}

output "region"   { value = "${var.region}" }
output "network"  { value = "${module.network.name}" }
output "vpc_cidr" { value = "${module.network.vpc_cidr}" }


output "info" {
  value = <<INFO

Utility server:
  ${module.compute.utility_name}: ${module.compute.utility_private_ip}/${module.compute.utility_public_ip} - ssh ubuntu@${module.compute.utility_public_ip}

  Graphite: http://${module.compute.utility_public_ip}

Consul servers:
    ${join("\n    ", formatlist("%s: %s/%s - ssh ubuntu@%s", split(",", module.compute.consul_server_names), split(",", module.compute.consul_server_private_ips), split(",", module.compute.consul_server_public_ips), split(",", module.compute.consul_server_public_ips)))}

Nomad servers:
    ${join("\n    ", formatlist("%s: %s/%s - ssh ubuntu@%s", split(",", module.compute.nomad_server_names), split(",", module.compute.nomad_server_private_ips), split(",", module.compute.nomad_server_public_ips), split(",", module.compute.nomad_server_public_ips)))}

consul dns:
    utility.service.consul
    redis.service.consul
    statsite.service.consul
    graphite.service.consul

    consul-server.service.consul
        ${var.region}.consul-server.service.consul
        ${join("\n        ", formatlist("%s.consul-server.service.consul", split(",", var.zones)))}
        ${var.consul_server_machine}.consul-server.service.consul

    nomad-server.service.consul
        ${var.region}.nomad-server.service.consul
        ${join("\n        ", formatlist("%s.nomad-server.service.consul", split(",", var.zones)))}
        ${var.nomad_server_machine}.nomad-server.service.consul

    nomad-client.service.consul
        ${var.region}.nomad-client.service.consul
        ${join("\n        ", formatlist("%s.nomad-client.service.consul", split(",", var.zones)))}
        ${var.nomad_client_machine}.nomad-client.service.consul
        NODE_CLASS.nomad-client.service.consul
INFO

}
