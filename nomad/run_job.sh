#!/bin/bash
set -e

scp -i ../id_rsa $1 ubuntu@$NOMAD_SERVER:/opt/nomad/jobs/
ssh -i ../id_rsa ubuntu@$NOMAD_SERVER nomad run -verbose /opt/nomad/jobs/$1
