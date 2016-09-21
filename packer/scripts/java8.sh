#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT haproxy.sh: $1"
}

CONFIGDIR=/ops/$1/consul

logger "Installing Java 8"

add-apt-repository -y ppa:webupd8team/java
apt-get update -y
# Automatically accept the license agreement
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
apt-get install -y oracle-java8-installer

logger "Completed"
