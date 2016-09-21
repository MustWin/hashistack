name              = "c1m"
region            = "us-central1"
project_id        = "nomadspark-143720" // CHANGEME
credentials_file  = "../../../gce-credentials.json" # GCE account credentials
public_key_file   = "../../../id_rsa.pub" # Added to all GCE instances and must be prefixed by the user ID which is allowed
private_key_file  = "../../../id_rsa"

artifact_type    = "google.image"
consul_log_level = "INFO"
nomad_log_level  = "INFO"
node_classes     = "5" # Number of node_classes we will be using for the challenge

artifact_prefix                = "packer"
utility_artifact_name          = "c1m-utility"
utility_artifact_version       = "1474446897"
consul_server_artifact_name    = "c1m-consul-server"
consul_server_artifact_version = "1474448743"
nomad_server_artifact_name     = "c1m-nomad-server"
nomad_server_artifact_version  = "1474448735"
nomad_client_artifact_name     = "c1m-nomad-client"
nomad_client_artifact_version  = "1474448731"

us_central1_cidr  = "10.140.0.0/16"
us_central1_zones = "us-central1-b" # ,us-central1-c,us-central1-f" # us-central1-a doesn't have n1_standard_32

# This creates client servers = nomad_clients * nomad_client_group
# Currently client_groups as single region only, but they're distributed
# accross us_central1_zones
utility_machine       = "n1-standard-1" # "n1-standard-8"
utility_disk          = "50" # In GB
consul_server_machine = "n1-standard-2" # "n1-standard-32"
consul_server_disk    = "10" # In GB
consul_servers        = "3"
nomad_server_machine  = "n1-standard-2" # "n1-standard-32"
nomad_server_disk     = "500" # In GB
nomad_servers         = "3"
nomad_client_machine  = "n1-standard-2" # "n1-standard-8"
nomad_client_disk     = "20" # In GB
nomad_client_groups   = "1"
nomad_clients         = "3"
