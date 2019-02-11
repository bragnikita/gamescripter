#!/usr/bin/env bash
rm -rf tmp/data
if [[ $# = 0 ]]; then
    DOCKER_ARGS="-d"
else
    DOCKER_ARGS="$@"
fi
docker-compose up ${DOCKER_ARGS}