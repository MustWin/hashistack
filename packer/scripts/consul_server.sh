#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT consul_server.sh: $1"
}

logger "Executing"

CONFIGDIR=/ops/$1

logger "Configure server"
cp ${CONFIGDIR}/consul/consul_server.json /etc/consul.d/.

logger "Completed"
