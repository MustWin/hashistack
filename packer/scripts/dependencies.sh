#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT dependencies.sh: $1"
}

logger "Executing"

logger "Update the box"
apt-get -y update
apt-get -y upgrade

logger "Install dependencies"
apt-get -y install curl zip unzip tar git build-essential jq

logger "Completed"
