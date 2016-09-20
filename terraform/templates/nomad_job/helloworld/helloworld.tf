variable "region"     { }
variable "datacenter" { }
variable "count"      { }
variable "image"      { }

resource "template_file" "helloworld" {
  template = "${file("${path.module}/helloworld.nomad.tpl")}"

  vars {
    region     = "${var.region}"
    datacenter = "${var.datacenter}"
    count      = "${var.count}"
    image      = "${var.image}"
  }
}

output "job" { value = "${template_file.helloworld.rendered}" }
