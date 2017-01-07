#!/bin/bash
set -e
sh $(dirname $0)/nomad/nomad.sh $1
sh $(dirname $0)/nomad/agent/java8.sh $1
sh $(dirname $0)/nomad/agent/docker.sh $2
sh $(dirname $0)/nomad/agent/nomad_agent.sh $1 # This calls nomad/agent/git_repo.sh
