#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT pq.sh: $1"
  echo "$DT pq.sh: $1" | sudo tee -a /var/log/user_data.log > /dev/null
}

logger "Begin script"

servers() {
  PASSING=$(curl -s "http://127.0.0.1:8500/v1/health/service/${consul_join_name}")

  # Check if valid json is returned, otherwise jq command fails
  if [[ "$PASSING" == [{* ]]; then
    echo $(echo $PASSING | jq -r '.[].Node.Address' | tr '\n' ' ')
  fi
}

sleep 15 # Wait for Consul service to fully boot
CONSUL_SERVERS=$(servers)
logger "Initial Consul servers: $CONSUL_SERVERS"
CONSUL_SERVER_LEN=$(echo $CONSUL_SERVERS | wc -w)
logger "Initial Consul server length: $CONSUL_SERVER_LEN"
SLEEPTIME=1

while [ $CONSUL_SERVER_LEN -lt 2 ]
do
  if [ $SLEEPTIME -gt 15 ]; then
    logger "ERROR: CONSUL SETUP NOT COMPLETE! Manual intervention required."
    exit 2
  else
    logger "Waiting for optimum quorum size, currently: $CONSUL_SERVER_LEN, waiting $SLEEPTIME seconds"
    CONSUL_SERVERS=$(servers)
    logger "Consul servers: $CONSUL_SERVERS"
    CONSUL_SERVER_LEN=$(echo $CONSUL_SERVERS | wc -w)
    logger "Consul server length: $CONSUL_SERVER_LEN"
    sleep $SLEEPTIME
    SLEEPTIME=$((SLEEPTIME + 1))
  fi
done

CONSUL_ADDR=http://127.0.0.1:8500

logger "Temporarily registering ${service} service for Prepared Query"
logger "$(
  curl \
    -H "Content-Type: application/json" \
    -LX PUT \
    -d '{ "Name": "${service}" }' \
    $CONSUL_ADDR/v1/agent/service/register
)"

logger "Registering ${service} Prepared Query"
logger "$(
  curl \
    -H "Content-Type: application/json" \
    -LX POST \
    -d \
'{
  "Name": "${service}",
  "Service": {
    "Service": "${service}",
    "Failover": {
      "NearestN": 3
    },
    "OnlyPassing": true,
    "Tags": ["global"]
  },
  "DNS": {
    "TTL": "10s"
  }
}' $CONSUL_ADDR/v1/query
)"

logger "Deregistering ${service} service"
logger "$(
  curl $CONSUL_ADDR/v1/agent/service/deregister/${service}
)"

sudo service consul start || sudo service consul restart

logger "Done"
