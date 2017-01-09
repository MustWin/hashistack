#!/bin/bash
: ${VAULT_SERVER?"Need to set VAULT_SERVER"}

set -e

ssh -i ../credentials/id_rsa ubuntu@$VAULT_SERVER "vault init" > $(dirname $0)/../credentials/vault.keys
