#!/bin/bash
: ${VAULT_SERVER?"Need to set VAULT_SERVER"}
: ${DOMAIN?"Need to set DOMAIN, e.g. example.com"}
: ${SUB?"Need to set SUB, e.g. sub in sub.example.com"}

VAULT_TOKEN=`cat $(dirname $0)/../credentials/vault.keys | grep 'Initial Root Token' | cut -f 2 -d ':'`
VAULT_AUTH_CMD="vault auth $VAULT_TOKEN"

# Issue a cert for an acme.com subdomain valid for 1 week
echo "Issue a subdomain cert"
CERT=$SUB.$DOMAIN.crt
SUBDOMAIN=${DOMAIN//\./\_}
ssh -i ../credentials/id_rsa ubuntu@$VAULT_SERVER "$VAULT_AUTH_CMD; vault write pki/issue/$SUBDOMAIN common_name=\"$SUB.$DOMAIN\" ttl=\"168h\" "
