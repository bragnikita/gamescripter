#!/usr/bin/env bash
set -e

FILE="$1"
if [[ ! -e "dbimport/${FILE}" ]]; then
    echo "File dbimport/${FILE} is not exists"
    exit 1
fi
DATABASE="${2:-gamescripter}"

docker-compose exec mongo bash -c "cd /import; ./exec_script.sh ${DATABASE} ${FILE};"