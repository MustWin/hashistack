#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT pq.sh: $1"
  echo "$DT pq.sh: $1" | sudo tee -a /var/log/user_data.log > /dev/null
}

logger "Begin script"

logger "running: consul join ${consul_servers}"

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

echo "Join succeeded, waiting for peers..."

SLEEPTIME=1
CONSUL_PEERS=`consul info | grep num_peers | cut -c 14-`
while [ $CONSUL_PEERS -lt 2 ]
do
  if [ $SLEEPTIME -gt 15 ]; then
    logger "ERROR: CONSUL SETUP NOT COMPLETE! Peers didn't join. Manual intervention required."
    exit 2
  else
    logger "Waiting for optimum quorum size, currently: $CONSUL_PEERS, waiting $SLEEPTIME seconds"
    sleep $SLEEPTIME
    SLEEPTIME=$((SLEEPTIME + 1))
    CONSUL_PEERS=`consul info | grep num_peers | cut -c 14-`
  fi
done

sleep 15 # Wait for Consul service to join and elect leader

logger "End script"
