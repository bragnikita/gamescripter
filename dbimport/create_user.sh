#!/usr/bin/env bash

set -e

DB=$1
PASSWORD="password"
ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
AUTH_DATABASE="admin"
SCRIPT="$(cat "create_db.js")"

mongo ${DB} --username ${ROOT_USERNAME} \
--password ${ROOT_PASSWORD} \
--authenticationDatabase ${AUTH_DATABASE} <<EOF
var database="${DB}";
var password="${PASSWORD}";
${SCRIPT}
EOF