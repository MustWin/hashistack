#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT collectd.sh: $1"
}

logger "Executing"

logger "Installing collectd"
apt-get -y install collectd collectd-utils

CONF_DIR=/etc/collectd
CONF=${CONF_DIR}/collectd.conf
PLUGIN_CONF_DIR=${CONF_DIR}/plugins

sed -i -- "s/#BaseDir \"\/var\/lib\/collectd\"/BaseDir \"\/var\/lib\/collectd\"/g" $CONF
sed -i -- "s/#PluginDir \"\/usr\/lib\/collectd\"/PluginDir \"\/usr\/lib\/collectd\"/g" $CONF
sed -i -- "s/#Interval 10/Interval 10/g" $CONF
sed -i -- "s/#ReadThreads 5/ReadThreads 5/g" $CONF

cat <<EOF >>${CONF}
Include "${PLUGIN_CONF_DIR}/*.conf"

LoadPlugin "write_graphite"
<Plugin "write_graphite">
 <Carbon>
   Host "graphite.service.consul"
   Port "2003"
   Prefix "collectd."
   #Protocol "udp"
 </Carbon>
</Plugin>

<Plugin "write_graphite">
 <Node "graphite">
   Host "graphite.service.consul"
   Port "2003"
   Prefix "collectd."
   #Postfix ""
   #Protocol "udp"
   #LogSendErrors false
   EscapeCharacter "_"
   SeparateInstances true
   StoreRates false
   AlwaysAppendDS false
 </Node>
</Plugin>

LoadPlugin "logfile"
<Plugin "logfile">
  LogLevel "info"
  File "/var/log/collectd.log"
  Timestamp true
</Plugin>
EOF

mkdir -p "${PLUGIN_CONF_DIR}"
cat <<EOF >${PLUGIN_CONF_DIR}/graphite.conf
<Plugin "write_graphite">
 <Carbon>
   Host "graphite.service.consul"
   Port "2003"
   Prefix "collectd."
   #Protocol "udp"
 </Carbon>
</Plugin>

<Plugin "write_graphite">
 <Node "graphite">
   Host "graphite.service.consul"
   Port "2003"
   Prefix "collectd."
   #Postfix ""
   #Protocol "udp"
   #LogSendErrors false
   EscapeCharacter "_"
   SeparateInstances true
   StoreRates false
   AlwaysAppendDS false
 </Node>
</Plugin>
EOF

cat <<EOF >${PLUGIN_CONF_DIR}/logfile.conf
<Plugin "logfile">
  LogLevel "info"
  File "/var/log/collectd.log"
  Timestamp true
</Plugin>
EOF

logger "Completed"
