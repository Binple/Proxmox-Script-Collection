#!/bin/sh

if [ -z "$1" ]; then
  echo "Usage: $0 <container_id>"
  exit 1
fi

CONTAINER_ID=$1

# apt update 및 apt upgrade
pct exec $CONTAINER_ID apt update
pct exec $CONTAINER_ID apt upgrade

# 로케일 업데이트
pct exec $CONTAINER_ID -- bash -c "sed -i '/# ko_KR.UTF-8 UTF-8/s/^# //' /etc/locale.gen"
pct exec $CONTAINER_ID locale-gen

# /etc/default/locale 파일 업데이트
pct exec $CONTAINER_ID -- bash -c "echo 'LANG=ko_KR.UTF-8
LANGUAGE=ko_KR.UTF-8
LC_ALL=ko_KR.UTF-8' > /etc/default/locale"
