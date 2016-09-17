#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT nomad_join.sh: $1"
  echo "$DT nomad_join.sh: $1" | sudo tee -a /var/log/user_data.log > /dev/null
}

logger "Begin script"

NOMAD_JOIN_NAME=$1
logger "Nomad join name: ${NOMAD_JOIN_NAME}"
SERVER=$2
logger "Nomad server: ${SERVER}"

servers() {
  PASSING=$(curl -s "http://127.0.0.1:8500/v1/health/service/${NOMAD_JOIN_NAME}")

  # Check if valid json is returned, otherwise jq command fails
  if [[ "$PASSING" == [{* ]]; then
   echo $(echo $PASSING | jq -r '.[].Node.Address' | tr '\n' ' ')
  fi
}

NOMAD_SERVERS=$(servers)
logger "Initial Nomad servers: $NOMAD_SERVERS"
NOMAD_SERVER_LEN=$(echo $NOMAD_SERVERS | wc -w)
logger "Initial Nomad server length: $NOMAD_SERVER_LEN"
SLEEPTIME=1

while [ $NOMAD_SERVER_LEN -lt 3 ]
do
  if [ $SLEEPTIME -gt 20 ]; then
    logger "ERROR: NOMAD SETUP NOT COMPLETE! Manual intervention required."
    exit 2
  else
    logger "Waiting for optimum quorum size, currently: $NOMAD_SERVER_LEN, waiting $SLEEPTIME seconds"
    NOMAD_SERVERS=$(servers)
    logger "Nomad servers: $NOMAD_SERVERS"
    NOMAD_SERVER_LEN=$(echo $NOMAD_SERVERS | wc -w)
    logger "Nomad server length: $NOMAD_SERVER_LEN"
    sleep $SLEEPTIME
    SLEEPTIME=$((SLEEPTIME + 1))
  fi
done

logger "Nomad server join"

if [ -z "$SERVER" ] || [ "$SERVER" == "client" ]; then
  # Adding port 4647 for clients to join
  NOMAD_SERVERS="${NOMAD_SERVERS} "
  NOMAD_SERVERS=${NOMAD_SERVERS// /$':4647 '}
  logger "Nomad client joining: ${NOMAD_SERVERS}"
  nomad client-config -update-servers ${NOMAD_SERVERS}
else
  logger "Nomad server joining: ${NOMAD_SERVERS}"
  nomad server-join ${NOMAD_SERVERS}
fi

logger "Done"
