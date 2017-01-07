#!/bin/bash

CONFIGDIR=/ops/$1/vault
CERTTARGET=/usr/local/share/ca-certificates/

mkdir -p $CERTTARGET
cp $CONFIGDIR/root.crt $CERTTARGET

sudo update-ca-certificates
