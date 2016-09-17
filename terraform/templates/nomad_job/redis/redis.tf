variable "region"     { }
variable "datacenter" { }
variable "count"      { }
variable "image"      { }

resource "template_file" "redis" {
  template = "${file("${path.module}/redis.nomad.tpl")}"

  vars {
    region     = "${var.region}"
    datacenter = "${var.datacenter}"
    count      = "${var.count}"
    image      = "${var.image}"
  }
}

output "job" { value = "${template_file.redis.rendered}" }
