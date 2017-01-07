#!/bin/bash

mkdir credentials
cd credentials

# Generate ssh keys for logging onto launched machines
ssh-keygen -t rsa -b 2048 -f id_rsa -P ""

echo "==========================================================="

cat <<EOF
We are creating 3 certificates:
1) a root certificate. Use a wildcard for the FQDN, e.g. *.example.com
2) a Consul certificate for encrypting consul communication.
3) a Vault certificate for issuing other certificates.
Please fill out the prompts for each and maintain the secrecy of your root keys!!
EOF
echo "==========================================================="

# Generate a root certificate
echo "==========================================================="
echo "====  Generating the root certificate. Remember to use a wildcard FQDN"
echo "==========================================================="
openssl req -newkey rsa:2048 -days 3650 -x509 -nodes -out root.crt -keyout root.key

# Set up the CA config. Create empty certindex and a serialfile with a hex value
echo 000a > serialfile
touch certindex

tee vault-ca.conf <<EOF
[ ca ]
default_ca = myca

[ myca ]
new_certs_dir = /tmp
unique_subject = no
certificate = `pwd`/root.crt
database = `pwd`/certindex
private_key = `pwd`/root.key
serial = `pwd`/serialfile
default_days = 365
default_md = sha1
policy = myca_policy
x509_extensions = myca_extensions
copy_extensions = copy

[ myca_policy ]
commonName = supplied
stateOrProvinceName = supplied
countryName = supplied
emailAddress = optional
organizationName = supplied
organizationalUnitName = optional

[ myca_extensions ]
basicConstraints = CA:false
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always
subjectAltName = IP:127.0.0.1,DNS:vault.service.consul
keyUsage = digitalSignature,keyEncipherment
extendedKeyUsage = serverAuth,clientAuth
EOF

echo "==========================================================="
echo "====  Generating the Consul certificate"
echo "==========================================================="
# Generate a cert signing request and key
openssl req -newkey rsa:2048 -nodes -out consul.csr -keyout consul.key
# Create the signed certificate for vault
openssl ca -batch -config vault-ca.conf -notext -in consul.csr -out consul.crt

echo "==========================================================="
echo "====  Generating the Vault certificate"
echo "==========================================================="
# Generate a cert signing request and key
openssl req -newkey rsa:2048 -nodes -out vault.csr -keyout vault.key
# Create the signed certificate for vault
openssl ca -batch -config vault-ca.conf -notext -in vault.csr -out vault.crt

# Move the cert & key into the packer consul & vault configs
cp consul.key ../packer/config/consul/
cp consul.crt ../packer/config/consul/
cp root.crt ../packer/config/consul/
cp vault.key ../packer/config/vault/
cp vault.crt ../packer/config/vault/
cp root.crt ../packer/config/vault/

echo "==========================================================="
echo "====  Generating the Consul secrets"
echo "==========================================================="
SECRET=`dd if=/dev/urandom bs=1 count=16 2>/dev/null | openssl base64`
find ../terraform/_env -type f -name '*.tf' -print0 | xargs -0 sed -i '.bak' 's/CONSUL_SERVER_ENCRYPT_KEY/$SECRET/g'
