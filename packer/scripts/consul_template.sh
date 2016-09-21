#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT consul_template.sh: $1"
}

logger "Installing consul-template"

CONFIGDIR=/ops/$1/consul
CONSULTEMPLATEVERSION=0.15.0
CONSULTEMPLATEDOWNLOAD=https://releases.hashicorp.com/consul-template/${CONSULTEMPLATEVERSION}/consul-template_${CONSULTEMPLATEVERSION}_linux_amd64.zip
CONSULTEMPLATECONFIGDIR=/etc/consul-template.d

cd /tmp

logger "Fetching Consul-Template"
logger "curl -L $CONSULTEMPLATEDOWNLOAD > consultemplate.zip"
curl -L $CONSULTEMPLATEDOWNLOAD > consultemplate.zip

logger "Installing Consul-Template"
unzip consultemplate.zip -d /usr/local/bin
chmod 0755 /usr/local/bin/consul-template
chown root:root /usr/local/bin/consul-template

logger "Configuring Consul"
mkdir -p "$CONSULTEMPLATECONFIGDIR"
chmod 0755 $CONSULTEMPLATECONFIGDIR

# Consul config
cp $CONFIGDIR/consul-template.hcl $CONSULTEMPLATECONFIGDIR/
cp $CONFIGDIR/consul-template.tpl $CONSULTEMPLATECONFIGDIR/

# Upstart config
cp $CONFIGDIR/upstart.consul-template /etc/init/consul-template.conf

logger "Completed"
