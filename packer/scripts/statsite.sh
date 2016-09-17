#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT statsite.sh: $1"
}

logger "Executing"

cd /tmp
rm -rf statsite

CONFIGDIR=/ops/$1/statsite
STATSITECONFIGDIR=/etc/statsite.d

logger "Install statsite dependencies"
apt-get -y install git build-essential scons

logger "Fetching statsite"
git clone --depth 1 https://github.com/armon/statsite.git

logger "Installing statsite"
cd statsite
make
cp statsite /usr/local/bin/.
chmod 0755 /usr/local/bin/statsite
chown root:root /usr/local/bin/statsite

logger "Configuring statsite"
mkdir -p "$STATSITECONFIGDIR"
chmod 0755 $STATSITECONFIGDIR
mkdir -p /opt/statsite
chmod 0755 /opt/statsite
mkdir -p /usr/share/statsite/sinks/
chmod 0755 /usr/share/statsite/sinks/
cp sinks/* /usr/share/statsite/sinks/

# Statsite config
cp $CONFIGDIR/default.conf $STATSITECONFIGDIR/.

# Upstart config
cp $CONFIGDIR/upstart.statsite /etc/init/statsite.conf

logger "Completed"
