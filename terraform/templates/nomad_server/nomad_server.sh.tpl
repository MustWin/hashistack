#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT nomad_server.sh: $1"
  echo "$DT nomad_server.sh: $1" | sudo tee -a /var/log/user_data.log > /dev/null
}

logger "Begin script"

logger "Configure Nomad Server"
NODE_NAME="$(hostname)"
logger "Node name: $NODE_NAME"

METADATA_LOCAL_IP=`curl ${local_ip_url}`
logger "Local IP: $METADATA_LOCAL_IP"

logger "Configuring Consul default"
CONSUL_DEFAULT_CONFIG=/etc/consul.d/default.json
CONSUL_DATA_DIR=${data_dir}/consul/data

sudo mkdir -p $CONSUL_DATA_DIR
sudo chmod 0755 $CONSUL_DATA_DIR

sudo sed -i -- "s/{{ data_dir }}/$${CONSUL_DATA_DIR//\//\\\/}/g" $CONSUL_DEFAULT_CONFIG
sudo sed -i -- "s/{{ local_ip }}/$METADATA_LOCAL_IP/g" $CONSUL_DEFAULT_CONFIG
sudo sed -i -- "s/{{ datacenter }}/${datacenter}/g" $CONSUL_DEFAULT_CONFIG
sudo sed -i -- "s/{{ node_name }}/$NODE_NAME/g" $CONSUL_DEFAULT_CONFIG
sudo sed -i -- "s/{{ log_level }}/${consul_log_level}/g" $CONSUL_DEFAULT_CONFIG

logger "Configuring Consul Nomad server"
CONSUL_NOMAD_SERVER_CONFIG=/etc/consul.d/nomad_server.json

sudo sed -i -- "s/\"{{ tags }}\"/\"${provider}\", \"${region}\", \"${zone}\", \"${machine_type}\"/g" $CONSUL_NOMAD_SERVER_CONFIG

echo $(date '+%s') | sudo tee -a /etc/consul.d/configured > /dev/null
sudo service consul start || sudo service consul restart

logger "Configuring Nomad default"
NOMAD_DEFAULT_CONFIG=/etc/nomad.d/default.hcl
NOMAD_DATA_DIR=${data_dir}/nomad/data

sudo mkdir -p $NOMAD_DATA_DIR
sudo chmod 0755 $NOMAD_DATA_DIR

sudo sed -i -- "s/{{ data_dir }}/$${NOMAD_DATA_DIR//\//\\\/}/g" $NOMAD_DEFAULT_CONFIG
sudo sed -i -- "s/{{ region }}/${region}/g" $NOMAD_DEFAULT_CONFIG
sudo sed -i -- "s/{{ datacenter }}/${datacenter}/g" $NOMAD_DEFAULT_CONFIG
sudo sed -i -- "s/{{ local_ip }}/$METADATA_LOCAL_IP/g" $NOMAD_DEFAULT_CONFIG
sudo sed -i -- "s/{{ node_id }}/$NODE_NAME/g" $NOMAD_DEFAULT_CONFIG
sudo sed -i -- "s/{{ name }}/$NODE_NAME/g" $NOMAD_DEFAULT_CONFIG
sudo sed -i -- "s/{{ log_level }}/${nomad_log_level}/g" $NOMAD_DEFAULT_CONFIG

logger "Configuring Nomad server"
NOMAD_SERVER_CONFIG=/etc/nomad.d/server.hcl

sudo sed -i -- "s/{{ local_ip }}/$METADATA_LOCAL_IP/g" $NOMAD_SERVER_CONFIG
sudo sed -i -- "s/{{ bootstrap_expect }}/${bootstrap_expect}/g" $NOMAD_SERVER_CONFIG

echo $(date '+%s') | sudo tee -a /etc/nomad.d/configured > /dev/null
sudo service nomad start || sudo service nomad restart

logger "Nomad server join: ${nomad_join_name}"
sleep 15 # Wait for Nomad service to fully boot
sudo /opt/nomad/nomad_join.sh "${nomad_join_name}" "server"

logger "Done"
