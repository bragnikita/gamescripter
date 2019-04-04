#!/usr/bin/env bash
set -e

openssl aes-256-cbc -k ${DEPLOY_KEY} -in config/server_key_enc -d -a -out config/server_key
eval "$(ssh-agent -s)"
chmod 600 config/server_key
ssh-add config/server_key
bundle exec cap production deploy:check