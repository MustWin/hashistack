#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT nomad_server.sh: $1"
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
sh /ops/packer/scripts/git_repo.sh $ORG $REPO $CHECKOUT

logger "Building $REPO binaries in $REPOPATH/bin"
cd ${REPOPATH}

logger "make bench-runner"
make default
cp bin/bench-runner /usr/local/bin/.
chmod 0755 /usr/local/bin/bench-runner
chown root:root /usr/local/bin/bench-runner

cd ${REPOPATH}/tests/nomad

logger "make bench-nomad"
make default
cp ../../bin/bench-nomad /usr/local/bin/.
chmod 0755 /usr/local/bin/bench-nomad
chown root:root /usr/local/bin/bench-nomad

logger "Create C1M job file directory"
mkdir -p "/opt/nomad/jobs"
chmod 0777 -R /opt/nomad

logger "Configure Nomad server"
cp ${CONFIGDIR}/nomad/server.hcl /etc/nomad.d/.
cp ${CONFIGDIR}/consul/nomad_server.json /etc/consul.d/.

logger "Completed"
