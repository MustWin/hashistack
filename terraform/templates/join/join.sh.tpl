#!/bin/bash

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT join.sh: $1"
  echo "$DT join.sh: $1" | sudo tee -a /var/log/user_data.log > /dev/null
}

logger "Begin script"

logger "running: consul join ${consul_servers}"

set +e        # Don't exit on errors while we wait for consul to start
consul join ${consul_servers}
retval=$?
SLEEPTIME=1
while [ $retval -ne 0 ]; do
    if [ $SLEEPTIME -gt 15 ]; then
      logger "ERROR: CONSUL SETUP NOT COMPLETE! Couldn't execute `join` Manual intervention required."
      exit $retval
    else
      logger "Consul join failed, retrying in $SLEEPTIME seconds"
      sleep $SLEEPTIME
      SLEEPTIME=$((SLEEPTIME + 1))
      consul join ${consul_servers}
      retval=$?
    fi
done
set -e

echo "Join succeeded, waiting for peers..."

SLEEPTIME=1
CONSUL_PEERS=`consul info | egrep "known_servers|num_peers" | tr ' ' '\n' | tail -n 1`
while [ $CONSUL_PEERS -lt 2 ]
do
  if [ $SLEEPTIME -gt 15 ]; then
    logger "ERROR: CONSUL SETUP NOT COMPLETE! Peers didn't join. Manual intervention required."
    exit 2
  else
    logger "Waiting for optimum quorum size, currently: $CONSUL_PEERS, waiting $SLEEPTIME seconds"
    sleep $SLEEPTIME
    SLEEPTIME=$((SLEEPTIME + 1))
    CONSUL_PEERS=`consul info | egrep "known_servers|num_peers" | tr ' ' '\n' | tail -n 1`
  fi
done

sleep 15 # Wait for Consul service to join and elect leader

logger "End script"
