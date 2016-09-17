#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT consul_master.sh: $1"
}

logger "Executing"

CONFIGDIR=/ops/$1/consul
GODIR=/usr/local
GOROOT=$GODIR/go
GOPATH=/opt/go
GOSRC=$GOPATH/src

export GOROOT=$GOROOT
export GOPATH=$GOPATH
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ORG=hashicorp
REPO=consul
CHECKOUT=master
ORGPATH=$GOSRC/github.com/$ORG
REPOPATH=$ORGPATH/$REPO

CONSULCONFIGDIR=/etc/consul.d
CONSULDIR=/opt/consul

logger "Pulling $ORG/$REPO repo"
sh /ops/packer/scripts/git_repo.sh $ORG $REPO $CHECKOUT

logger "Building $REPO binaries in $REPOPATH/bin"
cd $REPOPATH

logger "Consul: make all"
make all

logger "Checking out master"
git checkout master

logger "Installing Consul"
cp $GOPATH/bin/consul /usr/local/bin/.
chmod 0755 /usr/local/bin/consul
chown root:root /usr/local/bin/consul

logger "$(consul version)"

logger "Configuring Consul"
mkdir -p "$CONSULCONFIGDIR"
chmod 0755 $CONSULCONFIGDIR
mkdir -p "$CONSULDIR"
chmod 0755 $CONSULDIR

# Consul config
cp $CONFIGDIR/default.json $CONSULCONFIGDIR/.

# Upstart config
cp $CONFIGDIR/upstart.consul /etc/init/consul.conf

logger "Completed"
