#!/bin/bash

set -e
sh $(dirname $0)/consul_server/consul_server.sh $1
