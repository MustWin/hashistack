#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT haproxy.sh: $1"
}

CONFIGDIR=/ops/$1/consul

logger "Installing HAProxy"
apt-get -y install haproxy

# Upstart config
cp $CONFIGDIR/upstart.haproxy /etc/init/haproxy.conf


logger "Installing Dnsmasq"
apt-get -y install dnsmasq-base dnsmasq

logger "Configuring Dnsmasq"
cat <<EOF >/etc/dnsmasq.d/haproxy
address=/.service/127.0.0.2
EOF

cat /etc/dnsmasq.d/haproxy

logger "Restarting dnsmasq"
service dnsmasq start || service dnsmasq restart

logger "Completed"
