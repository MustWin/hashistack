variable "region"       { }
variable "datacenter"   { }
variable "nginx_count"  { }
variable "nginx_image"  { }
variable "nodejs_count" { }
variable "nodejs_image" { }

resource "template_file" "web" {
  template = "${file("${path.module}/web.nomad.tpl")}"

  vars {
    region       = "${var.region}"
    datacenter   = "${var.datacenter}"
    nginx_count  = "${var.nginx_count}"
    nginx_image  = "${var.nginx_image}"
    nodejs_count = "${var.nodejs_count}"
    nodejs_image = "${var.nodejs_image}"
  }
}

output "job" { value = "${template_file.web.rendered}" }
