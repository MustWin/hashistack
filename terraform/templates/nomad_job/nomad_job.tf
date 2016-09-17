variable "region"            { default = "global" }
variable "datacenter"        { default = "global" }
variable "classlogger_image" { default = "hashicorp/nomad-c1m:0.1" }
variable "redis_count"       { default = "1" }
variable "redis_image"       { default = "hashidemo/redis:latest" }
variable "nginx_count"       { default = "1" }
variable "nginx_image"       { default = "hashidemo/nginx:latest" }
variable "nodejs_count"      { default = "3" }
variable "nodejs_image"      { default = "hashidemo/nodejs:latest" }

module "classlogger_1" {
  source = "./classlogger"

  region     = "${var.region}"
  datacenter = "${var.datacenter}"
  count      = "1"
  image      = "${var.classlogger_image}"
}

module "classlogger_20" {
  source = "./classlogger"

  region     = "${var.region}"
  datacenter = "${var.datacenter}"
  count      = "20"
  image      = "${var.classlogger_image}"
}

module "classlogger_200" {
  source = "./classlogger"

  region     = "${var.region}"
  datacenter = "${var.datacenter}"
  count      = "200"
  image      = "${var.classlogger_image}"
}

module "classlogger_2000" {
  source = "./classlogger"

  region     = "${var.region}"
  datacenter = "${var.datacenter}"
  count      = "2000"
  image      = "${var.classlogger_image}"
}

module "redis" {
  source = "./redis"

  region     = "${var.region}"
  datacenter = "${var.datacenter}"
  count      = "${var.redis_count}"
  image      = "${var.redis_image}"
}

module "web" {
  source = "./web"

  region       = "${var.region}"
  datacenter   = "${var.datacenter}"
  nginx_count  = "${var.nginx_count}"
  nginx_image  = "${var.nginx_image}"
  nodejs_count = "${var.nodejs_image}"
  nodejs_image = "${var.nodejs_image}"
}

output "cmd" {
  value = <<CMD
echo "Creating job files"

echo "Creating C1M classlogger_1 job files"
cat > /opt/nomad/jobs/classlogger_1_docker.nomad <<EOF
${module.classlogger_1.docker_job}
EOF

cat > /opt/nomad/jobs/classlogger_1_consul_docker.nomad <<EOF
${module.classlogger_1.consul_docker_job}
EOF

cat > /opt/nomad/jobs/classlogger_1_raw_exec.nomad <<EOF
${module.classlogger_1.raw_exec_job}
EOF

cat > /opt/nomad/jobs/classlogger_1_consul_raw_exec.nomad <<EOF
${module.classlogger_1.consul_raw_exec_job}
EOF

echo "Creating C1M classlogger_20 job files"
cat > /opt/nomad/jobs/classlogger_20_docker.nomad <<EOF
${module.classlogger_20.docker_job}
EOF

cat > /opt/nomad/jobs/classlogger_20_consul_docker.nomad <<EOF
${module.classlogger_20.consul_docker_job}
EOF

cat > /opt/nomad/jobs/classlogger_20_raw_exec.nomad <<EOF
${module.classlogger_20.raw_exec_job}
EOF

cat > /opt/nomad/jobs/classlogger_20_consul_raw_exec.nomad <<EOF
${module.classlogger_20.consul_raw_exec_job}
EOF

echo "Creating C1M classlogger_200 job files"
cat > /opt/nomad/jobs/classlogger_200_docker.nomad <<EOF
${module.classlogger_200.docker_job}
EOF

cat > /opt/nomad/jobs/classlogger_200_consul_docker.nomad <<EOF
${module.classlogger_200.consul_docker_job}
EOF

cat > /opt/nomad/jobs/classlogger_200_raw_exec.nomad <<EOF
${module.classlogger_200.raw_exec_job}
EOF

cat > /opt/nomad/jobs/classlogger_200_consul_raw_exec.nomad <<EOF
${module.classlogger_200.consul_raw_exec_job}
EOF

echo "Creating C1M classlogger_2000 job files"
cat > /opt/nomad/jobs/classlogger_2000_docker.nomad <<EOF
${module.classlogger_2000.docker_job}
EOF

cat > /opt/nomad/jobs/classlogger_2000_consul_docker.nomad <<EOF
${module.classlogger_2000.consul_docker_job}
EOF

cat > /opt/nomad/jobs/classlogger_2000_raw_exec.nomad <<EOF
${module.classlogger_2000.raw_exec_job}
EOF

cat > /opt/nomad/jobs/classlogger_2000_consul_raw_exec.nomad <<EOF
${module.classlogger_2000.consul_raw_exec_job}
EOF

echo "Creating web example job files"
cat > /opt/nomad/jobs/redis.nomad <<EOF
${module.redis.job}
EOF

cat > /opt/nomad/jobs/web.nomad <<EOF
${module.web.job}
EOF

echo "Finished creating job files"
CMD
}
