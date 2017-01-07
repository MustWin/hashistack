#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT vault.sh: $1"
}

# For some reason, fetching nomad fails the first time around, so we retry
retry() {
  local n=1
  local max=5
  local delay=15
  while true; do
    "$@" && break || {
      if [ $n -lt $max ]; then
        n=$((n+1))
        # No output on failure to allow redirecting output
        sleep $delay;
      else
        fail "The command has failed after $n attempts."
      fi
    }
  done
}

logger "Executing"

cd /tmp

CONFIGDIR=/ops/$1/vault
VAULTVERSION=0.6.4
VAULTSHA=04d87dd553aed59f3fe316222217a8d8777f40115a115dac4d88fac1611c51a6
VAULTDOWNLOAD=https://releases.hashicorp.com/vault/${VAULTVERSION}/vault_${VAULTVERSION}_linux_amd64.zip
VAULTCONFIGDIR=/etc/vault.d
VAULTDIR=/opt/vault

logger "Fetching Vault"
retry curl -L $VAULTDOWNLOAD > vault.zip

echo "$VAULTSHA  vault.zip" | sha256sum -c | grep OK
if [ $? -ne 0 ]; then
  logger "ERROR: VAULT DOES NOT MATCH CHECKSUM"
  exit 1
fi

logger "Installing Vault"
unzip vault.zip -d /usr/local/bin
chmod 0755 /usr/local/bin/vault
chown root:root /usr/local/bin/vault

logger "Configuring Vault"
mkdir -p "$VAULTCONFIGDIR"
chmod 0755 $VAULTCONFIGDIR
mkdir -p "$VAULTDIR"
chmod 0755 $VAULTDIR

# Vault config
cp $CONFIGDIR/default.hcl $VAULTCONFIGDIR/.

# Upstart config
cp $CONFIGDIR/upstart.vault /etc/init/vault.conf

# Vault CA info
cp $CONFIGDIR/vault.crt $VAULTCONFIGDIR/.
cp $CONFIGDIR/vault.key $VAULTCONFIGDIR/.


logger "Completed"
