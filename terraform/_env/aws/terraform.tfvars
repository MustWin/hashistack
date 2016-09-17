name              = "c1m"
atlas_environment = "c1m-aws"
atlas_username    = "REPLACE_IN_ATLAS"
atlas_token       = "REPLACE_IN_ATLAS"
public_key        = "REPLACE_IN_ATLAS"
private_key       = "REPLACE_IN_ATLAS"

artifact_type    = "amazon.image"
consul_log_level = "INFO"
nomad_log_level  = "INFO"
node_classes     = "5" # Number of node_classes we will be using for the challenge

utility_artifact_name          = "c1m-utility"
utility_artifact_version       = "latest"
consul_server_artifact_name    = "c1m-consul-server"
consul_server_artifact_version = "latest"
nomad_server_artifact_name     = "c1m-nomad-server"
nomad_server_artifact_version  = "latest"
nomad_client_artifact_name     = "c1m-nomad-client"
nomad_client_artifact_version  = "latest"

us_east1_cidr            = "10.139.0.0/16"
us_east1_zones           = "us-east-1a,us-east-1c,us-east-1d"
us_east1_private_subnets = "10.139.1.0/24,10.139.2.0/24,10.139.3.0/24" # 1 private subnet per zone
us_east1_public_subnets  = "10.139.101.0/24,10.139.102.0/24,10.139.103.0/24" # 1 public subnet per zone

utility_machine       = "c3.2xlarge"
utility_disk          = "50" # In GB
consul_server_machine = "c3.8xlarge"
consul_server_disk    = "10" # In GB
consul_servers        = "3"
nomad_server_machine  = "c3.8xlarge"
nomad_server_disk     = "500" # In GB
nomad_servers         = "5"
nomad_client_machine  = "c3.2xlarge"
nomad_client_disk     = "20" # In GB
nomad_client_groups   = "10"
nomad_clients         = "5000"
