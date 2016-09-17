variable "name"              { }
variable "atlas_environment" { }
variable "atlas_username"    { }
variable "atlas_token"       { }
variable "project_id"        { }
variable "credentials"       { }
variable "ssh_keys"          { }
variable "private_key"       { }

variable "artifact_type"    { default = "google.image" }
variable "consul_log_level" { default = "INFO" }
variable "nomad_log_level"  { default = "INFO" }
variable "node_classes"     { default = "5" }

variable "utility_artifact_name"          { }
variable "utility_artifact_version"       { default = "latest" }
variable "consul_server_artifact_name"    { }
variable "consul_server_artifact_version" { default = "latest" }
variable "nomad_server_artifact_name"     { }
variable "nomad_server_artifact_version"  { default = "latest" }
variable "nomad_client_artifact_name"     { }
variable "nomad_client_artifact_version"  { default = "latest" }

variable "us_central1_region"     { default = "us-central1" }
variable "us_central1_cidr"       { default = "10.139.0.0/16" }
variable "us_central1_zones"      { default = "us-central1-b,us-central1-c,us-central1-f" }

variable "utility_machine"        { default = "n1-standard-8" }
variable "utility_disk"           { default = "50" }
variable "consul_server_machine"  { default = "n1-standard-32" }
variable "consul_server_disk"     { default = "10" }
variable "consul_servers"         { default = "3" }
variable "nomad_server_machine"   { default = "n1-standard-32" }
variable "nomad_server_disk"      { default = "500" }
variable "nomad_servers"          { default = "5" }
variable "nomad_client_machine"   { default = "n1-standard-8" }
variable "nomad_client_disk"      { default = "20" }
variable "nomad_client_groups"    { default = "10" }
variable "nomad_clients"          { default = "5000" }

provider "google" {
  credentials = "${var.credentials}"
}

atlas {
  name = "${var.atlas_username}/${var.atlas_environment}"
}

module "us_central1" {
  source = "../../gce/region"

  name              = "${var.name}"
  project_id        = "${var.project_id}"
  credentials       = "${var.credentials}"
  atlas_username    = "${var.atlas_username}"
  atlas_environment = "${var.atlas_environment}"
  atlas_token       = "${var.atlas_token}"

  region          = "${var.us_central1_region}"
  cidr            = "${var.us_central1_cidr}"
  zones           = "${var.us_central1_zones}"
  ssh_keys        = "${var.ssh_keys}"
  private_key     = "${var.private_key}"

  artifact_type    = "${var.artifact_type}"
  consul_log_level = "${var.consul_log_level}"
  nomad_log_level  = "${var.nomad_log_level}"
  node_classes     = "${var.node_classes}"

  utility_artifact_name    = "${var.utility_artifact_name}"
  utility_artifact_version = "${var.utility_artifact_version}"
  utility_machine          = "${var.utility_machine}"
  utility_disk             = "${var.utility_disk}"

  consul_server_artifact_name    = "${var.consul_server_artifact_name}"
  consul_server_artifact_version = "${var.consul_server_artifact_version}"
  consul_server_machine          = "${var.consul_server_machine}"
  consul_server_disk             = "${var.consul_server_disk}"
  consul_servers                 = "${var.consul_servers}"

  nomad_server_artifact_name    = "${var.nomad_server_artifact_name}"
  nomad_server_artifact_version = "${var.nomad_server_artifact_version}"
  nomad_server_machine          = "${var.nomad_server_machine}"
  nomad_server_disk             = "${var.nomad_server_disk}"
  nomad_servers                 = "${var.nomad_servers}"

  nomad_client_artifact_name    = "${var.nomad_client_artifact_name}"
  nomad_client_artifact_version = "${var.nomad_client_artifact_version}"
  nomad_client_machine          = "${var.nomad_client_machine}"
  nomad_client_disk             = "${var.nomad_client_disk}"
  nomad_client_groups           = "${var.nomad_client_groups}"
  nomad_clients                 = "${var.nomad_clients}"
}

output "us_central1_info" { value = "${module.us_central1.info}" }
