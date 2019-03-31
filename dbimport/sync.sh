#!/usr/bin/env bash

rsync -azhv --progress . "${1}:${2}"