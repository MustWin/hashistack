#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT cleanup.sh: $1"
}

logger "Executing"

logger "Cleanup"
apt-get -y autoremove
apt-get -y clean
# TODO: remove build essentials, etc

rm -rf /tmp/*
rm -rf /ops

logger "Completed"
