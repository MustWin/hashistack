#!/bin/bash
set -e

ssh -i ../credentials/id_rsa ubuntu@$VAULT_SERVER -c "vault init" > $(dirname $0)/../credentials/vault.keys
