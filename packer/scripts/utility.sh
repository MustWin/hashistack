#!/bin/bash
set -e
sh $(dirname $0)/utility/graphite.sh
sh $(dirname $0)/utility/redis.sh
sh $(dirname $0)/utility/statsite.sh
sh $(dirname $0)/utility/utility.sh $1
