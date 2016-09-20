variable "region"            { default = "global" }
variable "datacenter"        { default = "global" }

variable "redis_count"       { default = "1" }
variable "redis_image"       { default = "hashidemo/redis:latest" }

variable "helloworld_count" { default = 3 }
variable "helloworld_image" { default = "eveld/helloworld:1.0.0" }

module "helloworld" {
  source = "./helloworld"

  region     = "${var.region}"
  datacenter = "${var.datacenter}"
  count      = "1"
  image      = "${var.helloworld_image}"
}
output "helloworld_job" { value = "${module.helloworld.job}" }

module "redis" {
  source = "./redis"

  region     = "${var.region}"
  datacenter = "${var.datacenter}"
  count      = "${var.redis_count}"
  image      = "${var.redis_image}"
}
output "redis_job" { value = "${module.redis.job}" }
