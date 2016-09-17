#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT utility.sh: $1"
}

logger "Executing"

CONFIGDIR=/ops/$1

logger "Configure utility"
cp ${CONFIGDIR}/consul/utility.json /etc/consul.d/.
cp ${CONFIGDIR}/consul/redis.json /etc/consul.d/.
cp ${CONFIGDIR}/consul/statsite.json /etc/consul.d/.
cp ${CONFIGDIR}/consul/graphite.json /etc/consul.d/.

logger "Completed"
