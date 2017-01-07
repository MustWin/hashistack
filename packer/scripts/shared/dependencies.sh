#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT dependencies.sh: $1"
}

logger "Executing"

logger "Update the box"
apt-get -y update
# Sometimes gce assets don't work, added "&& true" so we don't fail on upgrades
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --fix-missing upgrade && true

logger "Install dependencies"
apt-get -y install curl zip unzip tar git build-essential jq

logger "Completed"
