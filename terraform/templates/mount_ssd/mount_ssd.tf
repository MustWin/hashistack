variable "mount_dir"      { }
variable "local_ssd_name" { }

resource "template_file" "mount_ssd" {
  template = "${file("${path.module}/mount_ssd.sh.tpl")}"

  vars {
    mount_dir      = "${var.mount_dir}"
    local_ssd_name = "${var.local_ssd_name}"
  }
}

output "script" { value = "${template_file.mount_ssd.rendered}" }
