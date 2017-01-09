#!/bin/bash
: ${VAULT_SERVER?"Need to set VAULT_SERVER"}
: ${DOMAIN?"Need to set DOMAIN, e.g. 'example.com'"}

set -e

VAULT_TOKEN=`cat $(dirname $0)/../credentials/vault.keys | grep 'Initial Root Token' | cut -f 2 -d ':'`
VAULT_AUTH_CMD="vault auth $VAULT_TOKEN"
VAULT_CERT=../packer/config/vault/vault.crt
VAULT_KEY=../packer/config/vault/vault.key
VAULT_INTERMEDIATE=vault_intermediate.crt

ssh -i ../credentials/id_rsa ubuntu@$VAULT_SERVER "$VAULT_AUTH_CMD; vault mount pki"

cat  $VAULT_CERT $VAULT_KEY > $VAULT_INTERMEDIATE
scp -i ../credentials/id_rsa $VAULT_INTERMEDIATE ubuntu@$VAULT_SERVER:~/$VAULT_INTERMEDIATE
ssh -i ../credentials/id_rsa ubuntu@$VAULT_SERVER "$VAULT_AUTH_CMD; vault write pki/config/ca pem_bundle=@$VAULT_INTERMEDIATE"
ssh -i ../credentials/id_rsa ubuntu@$VAULT_SERVER "rm ~/$VAULT_INTERMEDIATE"
rm $VAULT_INTERMEDIATE

# Create role for issuing acme.com certificates
# Max least time is 14 days
echo "Create a role for subdomain certs for $DOMAIN"
SUBDOMAIN=${DOMAIN//\./\_}
ssh -i ../credentials/id_rsa ubuntu@$VAULT_SERVER "$VAULT_AUTH_CMD; vault write pki/roles/$SUBDOMAIN allowed_domains=\"$DOMAIN\" lease_max=\"336h\" allow_subdomains=true allow_base_domain=true allow_bare_domains=true"
