#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT nomad.sh: $1"
}

logger "Executing"

cd /tmp

CONFIGDIR=/ops/$1/nomad
NOMADVERSION=0.4.0
NOMADDOWNLOAD=https://releases.hashicorp.com/nomad/${NOMADVERSION}/nomad_${NOMADVERSION}_linux_amd64.zip
NOMADCONFIGDIR=/etc/nomad.d
NOMADDIR=/opt/nomad

logger "Fetching Nomad"
curl -L $NOMADDOWNLOAD > nomad.zip

logger "Installing Nomad"
unzip nomad.zip -d /usr/local/bin
chmod 0755 /usr/local/bin/nomad
chown root:root /usr/local/bin/nomad

logger "Configuring Nomad"
mkdir -p "$NOMADCONFIGDIR"
chmod 0755 $NOMADCONFIGDIR
mkdir -p "$NOMADDIR"
chmod 0777 $NOMADDIR
mkdir "$NOMADDIR/data"

# Nomad config
cp $CONFIGDIR/default.hcl $NOMADCONFIGDIR/.

# Upstart config
cp $CONFIGDIR/upstart.nomad /etc/init/nomad.conf

# Nomad join script
cp $CONFIGDIR/nomad_join.sh $NOMADDIR/.
chmod +x $NOMADDIR/nomad_join.sh

logger "Completed"
