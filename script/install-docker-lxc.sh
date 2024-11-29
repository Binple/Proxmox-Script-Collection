#!/bin/sh

if [ -z "$1" ]; then
  echo "Usage: $0 <container_id>"
  exit 1
fi

CONTAINER_ID=$1

# apt update and apt upgrade
pct exec $CONTAINER_ID apt update
pct exec $CONTAINER_ID -- bash -c "apt upgrade -y"

# Add  Docker's official GPG key
pct exec $CONTAINER_ID -- bash -c "apt install -y ca-certificates curl"
pct exec $CONTAINER_ID -- bash -c "install -m 0755 -d /etc/apt/keyrings"
pct exec $CONTAINER_ID -- bash -c "curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc"
pct exec $CONTAINER_ID -- bash -c "chmod a+r /etc/apt/keyrings/docker.asc"

# Add Docker repository
pct exec $CONTAINER_ID -- bash -c "echo \
  \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  \$(. /etc/os-release && echo \$VERSION_CODENAME) stable\" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null"

# apt update
pct exec $CONTAINER_ID apt update

# install Docker
pct exec $CONTAINER_ID -- bash -c "apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"