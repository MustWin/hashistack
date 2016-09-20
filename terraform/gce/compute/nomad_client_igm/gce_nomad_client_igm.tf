variable "name"              { default = "nomad-client-igm" }
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
variable "groups"            { }
variable "nomad_clients"     { }
variable "node_classes"      { }
variable "nomad_join_name"   { default = "nomad-server?passing" }
variable "nomad_log_level"   { }
variable "consul_log_level"  { }
variable "ssh_keys"     { }
variable "private_key"  { }
variable "consul_servers"    { }

provider "google" {
  region      = "${var.region}"
  alias       = "${var.region}"
  project     = "${var.project_id}"
  credentials = "${var.credentials}"
}

module "consul_cluster_join_template" {
  source = "../../../templates/join"

  consul_servers   = "${var.consul_servers}"
}

module "nomad_client_template" {
  source = "../../../templates/nomad_client"
}

resource "template_file" "nomad_client_igm" {
  template = "${module.nomad_client_template.user_data}"
  count    = "${var.groups}"

  vars {
    consul_join_script = "${module.consul_cluster_join_template.script}"
    private_key       = "${var.private_key}"
    data_dir          = "/opt"
    provider          = "gce"
    region            = "gce-${var.region}"
    datacenter        = "gce-${var.region}"
    zone              = "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"
    machine_type      = "${var.machine_type}"
    node_class        = "class_${count.index % var.node_classes + 1}"
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

resource "google_compute_instance_template" "nomad_client_igm" {
  provider             = "google.${var.region}"
  count                = "${var.groups}"
  name                 = "${var.name}-${element(split(",", var.zones), count.index % length(split(",", var.zones)))}-${var.machine_type}-${count.index + 1}"
  description          = "${var.name}-${element(split(",", var.zones), count.index % length(split(",", var.zones)))}-${var.machine_type}-${count.index + 1}"
  instance_description = "${var.name}-${element(split(",", var.zones), count.index % length(split(",", var.zones)))}-${var.machine_type}-${count.index + 1}"
  machine_type         = "${var.machine_type}"

  tags = [
    "${var.name}-${element(split(",", var.zones), count.index % length(split(",", var.zones)))}-${var.machine_type}-${count.index + 1}",
    "${var.name}",
    "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}",
    "${var.machine_type}",
    "class-${count.index % var.node_classes + 1}",
  ]

  disk {
    boot         = true
    source_image = "${var.image}"
    disk_type    = "pd-ssd"
    disk_size_gb = "${var.disk_size}"
  }

  /*
  disk {
    disk_type   = "local-ssd"
    type        = "SCRATCH"
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
    startup-script = "${element(template_file.nomad_client_igm.*.rendered, count.index)}"
  }
}

resource "google_compute_instance_group_manager" "nomad_client_igm" {
  provider           = "google.${var.region}"
  count              = "${var.groups}"
  name               = "${var.name}-${element(split(",", var.zones), count.index % length(split(",", var.zones)))}-${var.machine_type}-${count.index + 1}"
  target_size        = "${var.nomad_clients / var.groups}"
  instance_template  = "${element(google_compute_instance_template.nomad_client_igm.*.self_link, count.index)}"
  base_instance_name = "${var.name}-${element(split(",", var.zones), count.index % length(split(",", var.zones)))}-${var.machine_type}-${count.index + 1}"
  zone               = "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"
}

/*
resource "google_compute_autoscaler" "nomad_client_igm" {
  provider = "google.${var.region}"
  count    = "${var.groups}"
  name     = "${var.name}-${element(split(",", var.zones), count.index % length(split(",", var.zones)))}-${var.machine_type}-${count.index + 1}"
  zone     = "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"
  target   = "${element(google_compute_instance_group_manager.nomad_client_igm.*.self_link, count.index)}"

  autoscaling_policy {
    max_replicas = "${var.nomad_clients / var.groups}"
    min_replicas = "${var.nomad_clients / var.groups}"

    cpu_utilization {
      target = 0.5
    }
  }
}
*/
