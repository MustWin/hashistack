variable "name"              { default = "utility" }
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
variable "consul_log_level"  { }
variable "ssh_keys"          { }
variable "private_key"       { }

provider "google" {
  region      = "${var.region}"
  alias       = "${var.region}"
  project     = "${var.project_id}"
  credentials = "${var.credentials}"
}

module "utility_template" {
  source = "../../../templates/utility"
}

resource "template_file" "utility" {
  template = "${module.utility_template.user_data}"

  vars {
    private_key       = "${var.private_key}"
    data_dir          = "/opt"
    atlas_username    = "${var.atlas_username}"
    atlas_environment = "${var.atlas_environment}"
    atlas_token       = "${var.atlas_token}"
    provider          = "gce"
    region            = "gce-${var.region}"
    datacenter        = "gce-${var.region}"
    zone              = "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"
    machine_type      = "${var.machine_type}"
    consul_log_level  = "${var.consul_log_level}"
    local_ip_url      = "-H \"Metadata-Flavor: Google\" http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/ip"
  }
}

module "mount_ssd_template" {
  source = "../../../templates/mount_ssd"

  mount_dir      = "${var.mount_dir}"
  local_ssd_name = "google-${var.local_ssd_name}"
}

resource "google_compute_instance" "utility" {
  provider     = "google.${var.region}"
  name         = "${var.name}-${element(split(",", var.zones), count.index % length(split(",", var.zones)))}-${var.machine_type}-${count.index + 1}"
  machine_type = "${var.machine_type}"
  zone         = "${element(split(",", var.zones), count.index)}"

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

  metadata_startup_script = "${template_file.utility.rendered}"
}

resource "google_compute_firewall" "allow-http" {
  name    = "${var.name}-allow-http"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.name}", "utility"]
}

output "name"         { value = "${google_compute_instance.utility.name}" }
output "machine_type" { value = "${google_compute_instance.utility.machine_type}" }
output "private_ip"   { value = "${google_compute_instance.utility.network_interface.0.address}" }
output "public_ip"    { value = "${google_compute_instance.utility.network_interface.0.access_config.0.assigned_nat_ip}" }
