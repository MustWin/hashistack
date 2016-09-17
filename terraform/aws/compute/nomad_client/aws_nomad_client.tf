variable "name"              { default = "nomad-client" }
variable "atlas_username"    { }
variable "atlas_environment" { }
variable "atlas_token"       { }
variable "region"            { }
variable "vpc_id"            { }
variable "vpc_cidr"          { }
variable "subnet_ids"        { }
variable "zones"             { }
variable "image"             { }
variable "machine_type"      { }
variable "disk_size"         { default = "10" }
variable "mount_dir"         { default = "/mnt/ssd0" }
variable "local_ssd_name"    { default = "local-ssd-0" }
variable "clients"           { }
variable "nomad_join_name"   { default = "nomad-server?passing" }
variable "nomad_log_level"   { }
variable "consul_log_level"  { }
variable "key_name"          { }
variable "private_key"       { }

provider "aws" {
  region = "${var.region}"
  alias  = "${var.region}"
}

module "nomad_client_template" {
  source = "../../../templates/nomad_client"
}

resource "template_file" "nomad_client" {
  template = "${module.nomad_client_template.user_data}"
  count    = "${var.node_classes}"

  vars {
    private_key       = "${var.private_key}"
    data_dir          = "/opt"
    atlas_username    = "${var.atlas_username}"
    atlas_environment = "${var.atlas_environment}"
    atlas_token       = "${var.atlas_token}"
    provider          = "aws"
    region            = "aws-${var.region}"
    datacenter        = "aws-${var.region}"
    machine_type      = "${var.machine_type}"
    zone              = "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"
    node_class        = "class_${count.index % var.node_classes + 1}"
    nomad_join_name   = "${var.nomad_join_name}"
    nomad_log_level   = "${var.nomad_log_level}"
    consul_log_level  = "${var.consul_log_level}"
    local_ip_url      = "http://169.254.169.254/2014-02-25/meta-data/local-ipv4"
  }
}

module "mount_ssd_template" {
  source = "../../../templates/mount_ssd"

  mount_dir      = "${var.mount_dir}"
  local_ssd_name = "aws-${var.local_ssd_name}"
}

resource "aws_security_group" "nomad_client" {
  provider    = "aws.${var.region}"
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "Security group for Nomad clients"

  tags { Name = "${var.name}" }

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nomad_client" {
  provider      = "aws.${var.region}"
  count         = "${var.clients}"
  ami           = "${var.image}"
  instance_type = "${var.machine_type}"
  key_name      = "${var.key_name}"
  subnet_id     = "${element(split(",", var.subnet_ids), count.index % length(split(",", var.subnet_ids)))}"
  user_data     = "${element(template_file.nomad_client.*.rendered, count.index)}"

  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.nomad_client.id}"]

  tags {
    Name    = "${var.name}-${element(split(",", var.zones), count.index % length(split(",", var.zones)))}-${count.index + 1}"
    Type    = "${var.name}"
    Zone    = "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"
    Machine = "${var.machine_type}"
  }

  root_block_device {
    volume_type = "gp2"
    volume_size = "${var.disk_size}"
  }

  /*
  ebs_block_device {
    volume_type = "io1"
    volume_size = "${var.disk_size}"
    iops        = "${var.disk_size * 10}"
    device_name = "${var.local_ssd_name}"
  }
  */
}

output "names"       { value = "${join(",", aws_instance.nomad_client.*.id)}" }
output "private_ips" { value = "${join(",", aws_instance.nomad_client.*.private_ip)}" }
output "public_ips"  { value = "${join(",", aws_instance.nomad_client.*.public_ip)}" }
