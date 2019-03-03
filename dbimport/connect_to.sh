#!/usr/bin/env bash

set -e

DB=$1
ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
AUTH_DATABASE="admin"


mongo ${DB} --username ${ROOT_USERNAME} \
--password ${ROOT_PASSWORD} \
--authenticationDatabase ${AUTH_DATABASE} --shell --eval "print('Logged in as ${ROOT_USERNAME}')"