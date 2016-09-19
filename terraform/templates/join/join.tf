variable "service"          { }
variable "consul_join_name" { }
variable "consul_servers" { }

resource "template_file" "join" {
  template = "${file("${path.module}/join.sh.tpl")}"

  vars {
    service          = "${var.service}"
    consul_join_name = "${var.consul_join_name}"
    consul_servers   = "${var.consul_servers}"
  }
}

output "script" { value = "${template_file.join.rendered}" }
