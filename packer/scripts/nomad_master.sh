#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT nomad_master.sh: $1"
}

logger "Executing"

CONFIGDIR=/ops/$1/nomad
GODIR=/usr/local
GOROOT=$GODIR/go
GOPATH=/opt/go
GOSRC=$GOPATH/src

export GOROOT=$GOROOT
export GOPATH=$GOPATH
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ORG=hashicorp
REPO=nomad
CHECKOUT=master
ORGPATH=$GOSRC/github.com/$ORG
REPOPATH=$ORGPATH/$REPO

NOMADCONFIGDIR=/etc/nomad.d
NOMADDIR=/opt/nomad

logger "Pulling $ORG/$REPO repo"
sh /ops/packer/scripts/git_repo.sh $ORG $REPO $CHECKOUT

logger "Building $REPO binaries in $REPOPATH/bin"
cd $REPOPATH

logger "Nomad: make bootstrap"
make bootstrap
logger "Nomad: make dev"
make dev

logger "Checking out master"
git checkout master

logger "Installing Nomad"
cp $GOPATH/bin/nomad /usr/local/bin/.
chmod 0755 /usr/local/bin/nomad
chown root:root /usr/local/bin/nomad

logger "$(nomad version)"

logger "Configuring Nomad"
mkdir -p "$NOMADCONFIGDIR"
chmod 0755 $NOMADCONFIGDIR
mkdir -p "$NOMADDIR"
chmod 0755 $NOMADDIR
mkdir "$NOMADDIR/data"

# Nomad config
cp $CONFIGDIR/default.hcl $NOMADCONFIGDIR/.

# Upstart config
cp $CONFIGDIR/upstart.nomad /etc/init/nomad.conf

# Nomad join script
cp $CONFIGDIR/nomad_join.sh $NOMADDIR/.
chmod +x $NOMADDIR/nomad_join.sh

logger "Completed"
