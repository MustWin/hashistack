#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT redis.sh: $1"
}

logger "Executing"

logger "Installing"
apt-get install -y redis-server

logger "Configuring Redis"
sed -i -- "s/bind 127.0.0.1/bind 0.0.0.0/g" /etc/redis/redis.conf

logger "Completed"
