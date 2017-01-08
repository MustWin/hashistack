backend "consul" {
  cluster_name = "vault"
  address = "127.0.0.1:8500"
  path = "vault"
  tls_ca_file = "/etc/consul.d/ssl/root.crt"
  tls_cert_file = "/etc/consul.d/ssl/consul.crt"
  tls_key_file = "/etc/consul.d/ssl/consul.key"
  // TODO: add consul ACL token
}

listener "tcp" {
  address = "127.0.0.1:8200"
  tls_cert_file = "/etc/vault.d/vault.crt"
  tls_key_file = "/etc/vault.d/vault.key"
}

telemetry {
  statsite_address = "127.0.0.1:8125"
  disable_hostname = true
}
