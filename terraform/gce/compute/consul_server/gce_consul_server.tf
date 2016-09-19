variable "name"              { default = "consul-server" }
variable "project_id"        { }
variable "region"            { }
variable "credentials"  { }
variable "network"           { default = "default" }
variable "zones"             { }
variable "image"             { }
variable "machine_type"      { }
variable "disk_size"         { default = "10" }
variable "mount_dir"         { default = "/mnt/ssd0" }
variable "local_ssd_name"    { default = "local-ssd-0" }
variable "consul_join_name"  { default = "consul-server?passing" }
variable "servers"           { }
variable "consul_log_level"  { }
variable "ssh_keys"      { }
variable "private_key"   { }


provider "google" {
  region      = "${var.region}"
  alias       = "${var.region}"
  project     = "${var.project_id}"
  credentials = "${var.credentials}"
}

module "consul_server_template" {
  source = "../../../templates/consul_server"
}

resource "template_file" "consul_server" {
  template = "${module.consul_server_template.user_data}"
  count    = "${var.servers}"

  vars {
    private_key     = "${var.private_key}"
    data_dir          = "/opt"
    provider          = "gce"
    region            = "gce-${var.region}"
    datacenter        = "gce-${var.region}"
    bootstrap_expect  = "${var.servers}"
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

resource "google_compute_instance" "consul_server" {
  provider     = "google.${var.region}"
  name         = "${var.name}-${element(split(",", var.zones), count.index % length(split(",", var.zones)))}-${var.machine_type}-${count.index + 1}"
  machine_type = "${var.machine_type}"
  zone         = "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"
  count        = "${var.servers}"

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

  metadata_startup_script = "${element(template_file.consul_server.*.rendered, count.index % var.servers)}"
}

module "consul_cluster_join_template" {
  source = "../../../templates/join"

  service          = "consul_join"
  consul_join_name = "${var.consul_join_name}"
  consul_servers   = "${join(" ", google_compute_instance.consul_server.*.network_interface.0.address)}"
}

resource "null_resource" "consul_cluster_join" {
  depends_on = ["google_compute_instance.consul_server"]

  triggers {
    private_ips = "${join(",", google_compute_instance.consul_server.*.network_interface.0.address)}"
  }

  connection {
    user        = "ubuntu"
    host        = "${google_compute_instance.consul_server.0.network_interface.0.access_config.0.assigned_nat_ip}"
    private_key     = "${var.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "${module.consul_cluster_join_template.script}",
    ]
  }
}


module "redis_pq_template" {
  source = "../../../templates/pq"

  service          = "redis"
  consul_join_name = "${var.consul_join_name}"
}

module "nodejs_pq_template" {
  source = "../../../templates/pq"

  service          = "nodejs"
  consul_join_name = "${var.consul_join_name}"
}

resource "null_resource" "prepared_queries" {
  depends_on = ["google_compute_instance.consul_server", "null_resource.consul_cluster_join"]

  triggers {
    private_ips = "${join(",", google_compute_instance.consul_server.*.network_interface.0.address)}"
  }

  connection {
    user        = "ubuntu"
    host        = "${google_compute_instance.consul_server.0.network_interface.0.access_config.0.assigned_nat_ip}"
    private_key     = "${var.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "${module.redis_pq_template.script}",
      "${module.nodejs_pq_template.script}",
    ]
  }
}

output "names"         { value = "${join(",", google_compute_instance.consul_server.*.name)}" }
output "machine_types" { value = "${join(",", google_compute_instance.consul_server.*.machine_type)}" }
output "private_ips"   { value = "${join(",", google_compute_instance.consul_server.*.network_interface.0.address)}" }
output "public_ips"    { value = "${join(",", google_compute_instance.consul_server.*.network_interface.0.access_config.0.assigned_nat_ip)}" }
