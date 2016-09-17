variable "name"              { default = "nomad-server" }
variable "project_id"        { }
variable "credentials"       { }
variable "atlas_username"    { }
variable "atlas_environment" { }
variable "atlas_token"       { }
variable "region"            { }
variable "network"           { default = "default" }
variable "zones"             { }
variable "image"             { }
variable "machine_type"      { }
variable "disk_size"         { default = "10" }
variable "mount_dir"         { default = "/mnt/ssd0" }
variable "local_ssd_name"    { default = "local-ssd-0" }
variable "servers"           { }
variable "nomad_join_name"   { default = "nomad-server?passing" }
variable "nomad_log_level"   { }
variable "consul_log_level"  { }
variable "ssh_keys"          { }
variable "private_key"       { }

provider "google" {
  region      = "${var.region}"
  alias       = "${var.region}"
  project     = "${var.project_id}"
  credentials = "${var.credentials}"
}

module "nomad_server_template" {
  source = "../../../templates/nomad_server"
}

resource "template_file" "nomad_server" {
  template = "${module.nomad_server_template.user_data}"
  count    = "${var.servers}"

  vars {
    private_key       = "${var.private_key}"
    data_dir          = "/opt"
    atlas_username    = "${var.atlas_username}"
    atlas_environment = "${var.atlas_environment}"
    atlas_token       = "${var.atlas_token}"
    provider          = "gce"
    region            = "gce-${var.region}"
    datacenter        = "gce-${var.region}"
    bootstrap_expect  = "${var.servers}"
    zone              = "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"
    machine_type      = "${var.machine_type}"
    nomad_join_name   = "${var.nomad_join_name}"
    nomad_log_level   = "${var.nomad_log_level}"
    consul_log_level  = "${var.consul_log_level}"
    local_ip_url      = "-H \"Metadata-Flavor: Google\" http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/ip"
  }
}

module "mount_ssd_template" {
  source = "../../../templates/mount_ssd"

  mount_dir      = "${var.mount_dir}"
  local_ssd_name = "google-${var.local_ssd_name}"
}

resource "google_compute_instance" "nomad_server" {
  provider     = "google.${var.region}"
  count        = "${var.servers}"
  name         = "${var.name}-${element(split(",", var.zones), count.index % length(split(",", var.zones)))}-${var.machine_type}-${count.index + 1}"
  zone         = "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"
  machine_type = "${var.machine_type}"

  tags = [
    "${var.name}-${element(split(",", var.zones), count.index % length(split(",", var.zones)))}-${count.index + 1}",
    "${var.name}",
    "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}",
    "${var.machine_type}",
  ]

  disk {
    image = "${var.image}"
    type  = "pd-ssd"
    size  = "${var.disk_size}"
  }

  /*
  disk {
    type        = "local-ssd"
    scratch     = true
    device_name = "${var.local_ssd_name}"
  }
  */

  network_interface {
    network = "${var.network}"

    access_config {
    }
  }

  metadata {
    sshKeys = "${var.ssh_keys}"
  }

  metadata_startup_script = "${element(template_file.nomad_server.*.rendered, count.index % var.servers)}"
}

module "nomad_jobs" {
  source = "../../../templates/nomad_job"

  region            = "gce-${var.region}"
  datacenter        = "gce-${var.region}"
  classlogger_image = "hashicorp/nomad-c1m:0.1"
  redis_count       = "1"
  redis_image       = "hashidemo/redis:latest"
  nginx_count       = "1"
  nginx_image       = "hashidemo/nginx:latest"
  nodejs_count      = "3"
  nodejs_image      = "hashidemo/nodejs:latest"
}

resource "null_resource" "nomad_jobs" {
  depends_on = ["google_compute_instance.nomad_server"]
  count      = "${var.servers}"

  triggers {
    private_ips = "${join(",", google_compute_instance.nomad_server.*.network_interface.0.address)}"
  }

  connection {
    user        = "ubuntu"
    host        = "${element(google_compute_instance.nomad_server.*.network_interface.0.access_config.0.assigned_nat_ip, count.index)}"
    private_key = "${var.private_key}"
  }

  provisioner "remote-exec" {
    inline = "${module.nomad_jobs.cmd}"
  }
}

output "names"         { value = "${join(",", google_compute_instance.nomad_server.*.name)}" }
output "machine_types" { value = "${join(",", google_compute_instance.nomad_server.*.machine_type)}" }
output "private_ips"   { value = "${join(",", google_compute_instance.nomad_server.*.network_interface.0.address)}" }
output "public_ips"    { value = "${join(",", google_compute_instance.nomad_server.*.network_interface.0.access_config.0.assigned_nat_ip)}" }
