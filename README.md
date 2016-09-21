# hashistack


## Setup

### Generate some keys for your deployment
```
# When prompted, put them in this directory and name the private key id_rsa and the public key id_rsa.pub
ssh-keygen -t rsa -b 2048
```

### Download google cloud credentials
Name them `gce-credentials.json` and put them in this folder

### Make copies of any relevant .template files, change any `CHANGEME` text

### Build the packer images
```
export GCE_PROJECT_ID=YOUR_GOOGLE_PROJECT_ID
export GCE_DEFAULT_ZONE=us-central1-a
export GCE_SOURCE_IMAGE=ubuntu-1404-trusty-v20160114e

packer build packer/gce_consul_server.json
packer build packer/gce_nomad_server.json
packer build packer/gce_nomad_client.json
packer build packer/gce_nomad_utility.json
```

### Fill in the version numbers in your tfvars

You'll need to swap the version numbers in your `terraform/_env/gce/terraform.tfvars` to match those built by packer for your project.

### Apply terraform

`cd terraform/_env/gce; terraform apply`
