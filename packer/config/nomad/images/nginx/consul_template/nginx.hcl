consul    = "127.0.0.1:8500"
max_stale = "10m"
retry     = "5s"
log_level = "warn"

template {
  source = "/opt/consul_template/nginx.ctmpl"
  destination = "/etc/nginx/nginx.conf"
  command = "service nginx restart"
}
