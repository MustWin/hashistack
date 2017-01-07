#!/bin/bash
set -e
sh $(dirname $0)/shared/dependencies.sh
sh $(dirname $0)/shared/trust_root_cert.sh $1
sh $(dirname $0)/shared/go.sh
sh $(dirname $0)/shared/collectd.sh
sh $(dirname $0)/shared/consul.sh $1
sh $(dirname $0)/shared/local_proxy/consul_template.sh $1
sh $(dirname $0)/shared/local_proxy/haproxy.sh $1
sh $(dirname $0)/shared/local_proxy/dnsmasq.sh $2
