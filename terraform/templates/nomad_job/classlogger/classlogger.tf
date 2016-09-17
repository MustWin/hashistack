variable "region"     { }
variable "datacenter" { }
variable "count"      { }
variable "image"      { }

resource "template_file" "docker" {
  template = "${file("${path.module}/docker.nomad.tpl")}"

  vars {
    region     = "${var.region}"
    datacenter = "${var.datacenter}"
    count      = "${var.count}"
    image      = "${var.image}"
  }
}

resource "template_file" "consul_docker" {
  template = "${file("${path.module}/consul_docker.nomad.tpl")}"

  vars {
    region     = "${var.region}"
    datacenter = "${var.datacenter}"
    count      = "${var.count}"
    image      = "${var.image}"
  }
}

resource "template_file" "raw_exec" {
  template = "${file("${path.module}/raw_exec.nomad.tpl")}"

  vars {
    region     = "${var.region}"
    datacenter = "${var.datacenter}"
    count      = "${var.count}"
  }
}

resource "template_file" "consul_raw_exec" {
  template = "${file("${path.module}/consul_raw_exec.nomad.tpl")}"

  vars {
    region     = "${var.region}"
    datacenter = "${var.datacenter}"
    count      = "${var.count}"
  }
}

output "docker_job"          { value = "${template_file.docker.rendered}" }
output "consul_docker_job"   { value = "${template_file.consul_docker.rendered}" }
output "raw_exec_job"        { value = "${template_file.raw_exec.rendered}" }
output "consul_raw_exec_job" { value = "${template_file.consul_raw_exec.rendered}" }
