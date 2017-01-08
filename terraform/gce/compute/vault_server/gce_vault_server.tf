variable "name"              { default = "vault-server" }
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
variable "servers"           { }
variable "consul_log_level"  { }
variable "ssh_keys"          { }
variable "private_key"       { }
variable "consul_servers"    { }
variable "consul_server_encrypt_key" { }

provider "google" {
  region      = "${var.region}"
  alias       = "${var.region}"
  project     = "${var.project_id}"
  credentials = "${var.credentials}"
}


module "vault_server_template" {
  source = "../../../templates/vault_server"
}

resource "template_file" "vault_server" {
  template = "${module.vault_server_template.user_data}"
  count    = "${var.servers}"

  vars {
    private_key       = "${var.private_key}"
    data_dir          = "/opt"
    provider          = "gce"
    region            = "gce-${var.region}"
    datacenter        = "gce-${var.region}"
    bootstrap_expect  = "${var.servers}"
    zone              = "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"
    machine_type      = "${var.machine_type}"
    consul_log_level  = "${var.consul_log_level}"
    local_ip_url      = "-H \"Metadata-Flavor: Google\" http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/ip"
    consul_server_encrypt_key = "${var.consul_server_encrypt_key}"
  }
}


module "consul_cluster_join_template" {
  source = "../../../templates/join"

  consul_servers   = "${var.consul_servers}"
}

module "mount_ssd_template" {
  source = "../../../templates/mount_ssd"

  mount_dir      = "${var.mount_dir}"
  local_ssd_name = "google-${var.local_ssd_name}"
}

resource "google_compute_instance" "vault_server" {
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
    sshKeys        = "${var.ssh_keys}"
  }

  metadata_startup_script = "${element(template_file.vault_server.*.rendered, count.index % var.servers)}"

  provisioner "remote-exec" {
    connection {
      user          = "ubuntu"
      private_key   = "${var.private_key}"
    }
    inline = [
      "${module.consul_cluster_join_template.script}",
    ]
  }
}

output "names"         { value = "${join(",", google_compute_instance.vault_server.*.name)}" }
output "machine_types" { value = "${join(",", google_compute_instance.vault_server.*.machine_type)}" }
output "private_ips"   { value = "${join(",", google_compute_instance.vault_server.*.network_interface.0.address)}" }
output "public_ips"    { value = "${join(",", google_compute_instance.vault_server.*.network_interface.0.access_config.0.assigned_nat_ip)}" }
