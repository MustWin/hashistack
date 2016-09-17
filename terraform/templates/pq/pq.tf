variable "service"          { }
variable "consul_join_name" { }

resource "template_file" "pq" {
  template = "${file("${path.module}/pq.sh.tpl")}"

  vars {
    service          = "${var.service}"
    consul_join_name = "${var.consul_join_name}"
  }
}

output "script" { value = "${template_file.pq.rendered}" }
