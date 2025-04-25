#!/bin/bash

PROCESS_NAME="/root/.rpi-web-shell/venv/bin/python"

if ! docker exec web-shell-systemd systemctl is-active --quiet rpi-shell.service || ! docker exec web-shell-systemd ps aux | grep -q "[${PROCESS_NAME}]"; then
  echo
  echo "Restarting container.."
  echo $(date)
  cd /home/qincai/docker/linux/web-shell-fedora/systemd
  docker compose kill; docker compose down; docker compose up -d
fi
