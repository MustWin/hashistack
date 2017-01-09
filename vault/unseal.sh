#!/bin/bash
: ${VAULT_SERVER?"Need to set VAULT_SERVER"}
set -e

IFS=$'\n'
CREDENTIALS=`head -n 5 ../credentials/vault.keys | cut -c 15-`
echo $CREDENTIALS
for key in ${CREDENTIALS}; do
  echo "vault unseal $key"
  ssh -i ../credentials/id_rsa ubuntu@$VAULT_SERVER "vault unseal $key"
done
