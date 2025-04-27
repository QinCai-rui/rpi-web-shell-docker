# RPi Web Shell Docker Edition

## Build status
[![Docker](https://github.com/QinCai-rui/rpi-web-shell-docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/QinCai-rui/rpi-web-shell-docker/actions/workflows/docker-publish.yml)

This is a Docker implementation of <https://github.com/qincai-rui/rpi-web-shell>

Build and run the container to try it out:

```bash
git clone https://github.com/qincai-rui/rpi-web-shell-docker
cd rpi-web-shell-docker
docker compose up --build 
```

, or use the prebuilt image (linux-amd64 and linux-arm64, see [docker-compose.yml](https://github.com/QinCai-rui/rpi-web-shell-docker/blob/master/docker-compose.yml))

Then go to <http://localhost:5002> on the host machine!
