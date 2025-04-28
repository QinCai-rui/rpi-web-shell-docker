#!/bin/bash

cd /home/qincai/docker/web-shell-fedora/
docker compose kill; docker compose down; docker compose up -d
