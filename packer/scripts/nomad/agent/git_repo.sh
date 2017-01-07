#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT git_repo.sh: $1"
}

logger "Executing"

ORG=$1
REPO=$2
CHECKOUT=$3
GITUSERNAME=$4
GITPASSWORD=$5
GOSRC=/opt/go/src

mkdir -p "$GOSRC"
chmod 0755 $GOSRC

ORGPATH=$GOSRC/github.com/$ORG
REPOPATH=$ORGPATH/$REPO

if ! [ -d "$ORGPATH" ]; then
  mkdir -p "$ORGPATH"
  chmod 0755 $ORGPATH
fi

cd $ORGPATH

if ! [ -d "$REPOPATH" ] || ! [ "$(ls -A $REPOPATH)" ]; then
  logger "Fetching ${ORG}/${REPO} from GitHub"

  if [ -z "$GITUSERNAME" ] || [ -z "$GITPASSWORD" ]; then
    git clone https://github.com/${ORG}/${REPO}.git
  else
    git clone https://${GITUSERNAME}:${GITPASSWORD}@github.com/${ORG}/${REPO}.git
  fi
fi

mkdir -p "$REPOPATH"
cd $REPOPATH

git checkout $CHECKOUT

logger "Completed"
