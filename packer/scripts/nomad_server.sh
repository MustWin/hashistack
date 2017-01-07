#!/bin/bash
set -e
sh $(dirname $0)/nomad/nomad.sh $1
sh $(dirname $0)/nomad/server/nomad_server.sh $1
