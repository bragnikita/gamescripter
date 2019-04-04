#!/usr/bin/env bash
set -e

[[ $TRAVIS_BRANCH != "$1" ]] && exit 0

openssl aes-256-cbc -k ${DEPLOY_KEY} -in config/server_key_enc -d -a -out config/server_key
eval "$(ssh-agent -s)"
chmod 600 config/server_key
ssh-add config/server_key
bundle exec cap production deploy:check
bundle exec cap production deploy

echo "======== Deploy success =========="