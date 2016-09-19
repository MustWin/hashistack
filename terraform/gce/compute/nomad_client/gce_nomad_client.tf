variable "name"              { default = "nomad-client" }
variable "project_id"        { }
variable "credentials"       { }
variable "region"            { }
variable "network"           { default = "default" }
variable "zones"             { }
variable "image"             { }
variable "machine_type"      { }
variable "disk_size"         { default = "10" }
variable "mount_dir"         { default = "/mnt/ssd0" }
variable "local_ssd_name"    { default = "local-ssd-0" }
variable "nomad_clients"     { }
variable "node_classes"      { }
variable "nomad_join_name"   { default = "nomad-server?passing" }
variable "nomad_log_level"   { }
variable "consul_log_level"  { }
variable "ssh_keys"   { }
variable "private_key"  { }

provider "google" {
  region      = "${var.region}"
  alias       = "${var.region}"
  project     = "${var.project_id}"
  credentials = "${var.credentials}"
}

module "nomad_client_template" {
  source = "../../../templates/nomad_client"
}

resource "template_file" "nomad_client" {
  template = "${module.nomad_client_template.user_data}"
  count    = "${var.node_classes}"

  vars {
    private_key       = "${var.private_key}"
    data_dir          = "/opt"
    provider          = "gce"
    region            = "gce-${var.region}"
    datacenter        = "gce-${var.region}"
    zone              = "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"
    machine_type      = "${var.machine_type}"
    node_class        = "class_${count.index + 1}"
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

resource "google_compute_instance" "nomad_client" {
  provider     = "google.${var.region}"
  count        = "${var.nomad_clients}"
  name         = "${var.name}-${element(split(",", var.zones), (count.index % var.node_classes) % (length(split(",", var.zones))))}-${var.machine_type}-${count.index + 1}"
  machine_type = "${var.machine_type}"
  zone         = "${element(split(",", var.zones), (count.index % var.node_classes) % (length(split(",", var.zones))))}"

  tags = [
    "${var.name}-${element(split(",", var.zones), (count.index % var.node_classes) % (length(split(",", var.zones))))}-${var.machine_type}-${count.index + 1}",
    "${var.name}",
    "${element(split(",", var.zones), (count.index % var.node_classes) % (length(split(",", var.zones))))}",
    "${var.machine_type}",
    "class-${(count.index % var.node_classes) + 1}",
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
    sshKeys        = "${var.ssh_keys}"
  }

  metadata_startup_script = "${element(template_file.nomad_client.*.rendered, count.index % var.node_classes)}"
}
