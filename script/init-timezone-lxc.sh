#!/bin/sh

if [ -z "$1" ]; then
  echo "Usage: $0 <container_id>"
  exit 1
fi

CONTAINER_ID=$1

# apt update 및 apt upgrade
pct exec $CONTAINER_ID apt update
pct exec $CONTAINER_ID -- bash -c "apt upgrade -y"

# 시간대 설정 (Asia/Seoul)
pct exec $CONTAINER_ID -- bash -c "echo 'Asia/Seoul' > /etc/timezone"
pct exec $CONTAINER_ID -- bash -c "ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime"
pct exec $CONTAINER_ID -- bash -c "dpkg-reconfigure -f noninteractive tzdata"