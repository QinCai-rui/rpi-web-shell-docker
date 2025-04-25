#!/bin/bash

cd /home/qincai/docker/linux/web-shell-fedora/systemd
docker compose kill; docker compose down; docker compose up -d
