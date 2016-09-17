variable "name"              { }
variable "atlas_environment" { }
variable "atlas_username"    { }
variable "atlas_token"       { }
variable "public_key"        { }
variable "private_key"       { }

variable "artifact_type"    { default = "amazon.image" }
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

variable "us_east1_region"          { default = "us-east-1" }
variable "us_east1_cidr"            { default = "10.139.0.0/16" }
variable "us_east1_zones"           { default = "us-east-1a,us-east-1c,us-east-1e" }
variable "us_east1_private_subnets" { default = "10.139.1.0/24,10.139.2.0/24,10.139.3.0/24" }
variable "us_east1_public_subnets"  { default = "10.139.101.0/24,10.139.102.0/24,10.139.103.0/24" }

variable "utility_machine"       { default = "c3.2xlarge" }
variable "utility_disk"          { default = "50" }
variable "consul_server_machine" { default = "c3.8xlarge" }
variable "consul_server_disk"    { default = "10" }
variable "consul_servers"        { default = "3" }
variable "nomad_server_machine"  { default = "c3.8xlarge" }
variable "nomad_server_disk"     { default = "500" }
variable "nomad_servers"         { default = "5" }
variable "nomad_client_machine"  { default = "c3.2xlarge" }
variable "nomad_client_disk"     { default = "20" }
variable "nomad_client_groups"   { default = "10" }
variable "nomad_clients"         { default = "5000" }

provider "aws" { }

atlas {
  name = "${var.atlas_username}/${var.atlas_environment}"
}

resource "aws_key_pair" "key" {
  key_name   = "${var.atlas_environment}"
  public_key = "${var.public_key}"
}

module "us_east1" {
  source = "../../aws/region"

  name              = "${var.name}"
  atlas_username    = "${var.atlas_username}"
  atlas_environment = "${var.atlas_environment}"
  atlas_token       = "${var.atlas_token}"

  region          = "${var.us_east1_region}"
  cidr            = "${var.us_east1_cidr}"
  zones           = "${var.us_east1_zones}"
  private_subnets = "${var.us_east1_private_subnets}"
  public_subnets  = "${var.us_east1_public_subnets}"
  key_name        = "${aws_key_pair.key.key_name}"
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

output "us_east1_info" { value = "${module.us_east1.info}" }
