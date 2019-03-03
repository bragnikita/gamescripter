#!/usr/bin/env bash

set -e

DB=$1
ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
AUTH_DATABASE="admin"

if [[ ! -z "$2" ]]; then
    echo "from file"
    SCRIPT="$(cat "$2")"
else
    SCRIPT=$(cat -)
fi

mongo ${DB} --username ${ROOT_USERNAME} \
--password ${ROOT_PASSWORD} \
--authenticationDatabase ${AUTH_DATABASE} <<EOF
${SCRIPT}
EOF