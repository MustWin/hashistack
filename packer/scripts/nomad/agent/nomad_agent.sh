#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT nomad_agent.sh: $1"
}

logger "Executing"

CONFIGDIR=/ops/$1
GODIR=/usr/local
GOROOT=$GODIR/go
GOPATH=/opt/go
GOSRC=$GOPATH/src

export GOROOT=$GOROOT
export GOPATH=$GOPATH
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ORG=hashicorp
REPO=c1m
CHECKOUT=master
ORGPATH=$GOSRC/github.com/$ORG
REPOPATH=$ORGPATH/$REPO/schedbench

logger "Pulling $ORG/$REPO repo"
sh $(dirname $0)/git_repo.sh $ORG $REPO $CHECKOUT

logger "Building $REPO binaries in $REPOPATH/bin"
cd ${REPOPATH}/tests/nomad

logger "make docker - builds classlogger and Docker image containing classlogger"
make docker

cp classlogger/classlogger /usr/bin/.
chmod 0755 /usr/bin/classlogger
chown root:root /usr/bin/classlogger

logger "Configure client"
cp ${CONFIGDIR}/nomad/client.hcl /etc/nomad.d/.
cp ${CONFIGDIR}/consul/nomad_client.json /etc/consul.d/.

logger "Completed"
