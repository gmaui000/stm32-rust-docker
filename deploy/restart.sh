#!/bin/bash
SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

docker-compose pull
docker-compose down
docker-compose up -d

