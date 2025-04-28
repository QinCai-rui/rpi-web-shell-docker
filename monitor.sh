#!/bin/bash

PROCESS_NAME="python"

if ! docker exec web-shell-systemd ps aux | grep -q "[${PROCESS_NAME}]"; then
  echo
  echo "Restarting container.."
  echo $(date)
  cd /home/qincai/docker/web-shell-fedora/
  docker compose kill; docker compose down; docker compose up -d
fi
