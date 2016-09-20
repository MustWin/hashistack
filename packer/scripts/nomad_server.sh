#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT nomad_server.sh: $1"
}

logger "Executing"

CONFIGDIR=/ops/$1

logger "Create C1M job file directory"
mkdir -p "/opt/nomad/jobs"
chmod 0777 -R /opt/nomad

logger "Configure Nomad server"
cp ${CONFIGDIR}/nomad/server.hcl /etc/nomad.d/.
cp ${CONFIGDIR}/consul/nomad_server.json /etc/consul.d/.

logger "Completed"
