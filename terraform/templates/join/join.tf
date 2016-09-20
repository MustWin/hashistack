variable "consul_servers" { }

resource "template_file" "join" {
  template = "${file("${path.module}/join.sh.tpl")}"

  vars {
    consul_servers   = "${var.consul_servers}"
  }
}

output "script" { value = "${template_file.join.rendered}" }
