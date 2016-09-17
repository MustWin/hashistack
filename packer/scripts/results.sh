#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT results.sh: $1"
}

logger "Executing"

logger "Configure results gathering"
mkdir -p /home/ubuntu/c1m/results
mkdir -p /home/ubuntu/c1m/logs
mkdir -p /home/ubuntu/c1m/spawn
chmod 0777 -R /home/ubuntu/c1m

cat <<EOF >/etc/init/spawn.conf
description "Instance spawn time"

start on runlevel [2345]
stop on runlevel [!2345]

console log

script
  echo "instance,\$(hostname),\$(date '+%s')" | sudo tee -a /home/ubuntu/c1m/spawn/spawn.csv
end script
EOF

logger "Completed"
