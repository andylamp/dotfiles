#!/bin/bash

# This script is designed to stop, remove, and delete any containers and/or data left by the pihole-docker script
#

# the grafana dockerfile name - this has to be present!
PI_HOLE_DOCKERFILE=pihole.yaml
# the project name
DOCK_PROJECT_NAME="pihole"

docker-compose -p ${DOCK_PROJECT_NAME} -f ${PI_HOLE_DOCKERFILE} down && \
docker container prune -f && \
# remove the data stored by grafana and prometheus - you might need to change these
sudo rm -rf /usr/pihole