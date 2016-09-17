#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT consul.sh: $1"
}

logger "Executing"

cd /tmp

CONFIGDIR=/ops/$1/consul
CONSULVERSION=0.6.4
CONSULDOWNLOAD=https://releases.hashicorp.com/consul/${CONSULVERSION}/consul_${CONSULVERSION}_linux_amd64.zip
CONSULWEBUI=https://releases.hashicorp.com/consul/${CONSULVERSION}/consul_${CONSULVERSION}_web_ui.zip
CONSULCONFIGDIR=/etc/consul.d
CONSULDIR=/opt/consul

logger "Fetching Consul"
curl -L $CONSULDOWNLOAD > consul.zip

logger "Installing Consul"
unzip consul.zip -d /usr/local/bin
chmod 0755 /usr/local/bin/consul
chown root:root /usr/local/bin/consul

logger "Configuring Consul"
mkdir -p "$CONSULCONFIGDIR"
chmod 0755 $CONSULCONFIGDIR
mkdir -p "$CONSULDIR"
chmod 0755 $CONSULDIR

# Consul config
cp $CONFIGDIR/default.json $CONSULCONFIGDIR/.

# Upstart config
cp $CONFIGDIR/upstart.consul /etc/init/consul.conf

curl -L $CONSULWEBUI > ui.zip
unzip ui.zip -d $CONSULDIR/ui

logger "Completed"
