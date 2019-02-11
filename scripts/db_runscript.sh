#!/usr/bin/env bash
set -e

FILE="$1"
if [[ ! -e "dbimport/${FILE}" ]]; then
    echo "File dbimport/${FILE} is not exists"
    exit 1
fi

docker-compose exec mongo mongo /import/${FILE} --username dba --password pass