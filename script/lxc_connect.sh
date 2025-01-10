#!/bin/bash

# Safe Script Execution Settings
set -e

# 루트 권한 확인
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with root privileges."
    exit 1
fi

# 사용자 입력값 확인
if [[ -n $1 ]]; then
    # 입력값이 있는 경우 해당 CTID로 바로 접속
    CTID=$1
    STATE=$(pct status "$CTID" 2>/dev/null | awk '{print $2}')
    if [[ -z $STATE ]]; then
        echo "CTID $CTID에 해당하는 컨테이너가 존재하지 않습니다."
        exit 1
    fi
    if [[ $STATE != "running" ]]; then
        echo "컨테이너 $CTID가 실행 중이 아닙니다. 실행 후 접속하시겠습니까? (y/n): "
        read -r confirm
        if [[ $confirm == "y" ]]; then
            pct start "$CTID"
            echo "컨테이너 $CTID를 시작했습니다."
        else
            echo "접속을 취소합니다."
            exit 0
        fi
    fi
    echo "컨테이너 $CTID에 접속 중..."
    echo "$(date): 사용자 $(whoami) - 컨테이너 $CTID에 접속" >> /var/log/lxc_access.log
    pct enter "$CTID"
    exit 0
fi

# pct list 명령어로 컨테이너 목록 가져오기
mapfile -t containers < <(pct list | tail -n +2 | awk '{print $1, $2, $3}')

# 컨테이너가 없는 경우 처리
if [[ ${#containers[@]} -eq 0 ]]; then
    echo "LXC 컨테이너가 없습니다."
    exit 1
fi

# 컨테이너 목록 출력
echo "=== LXC 컨테이너 목록 ==="
counter=1
for container in "${containers[@]}"; do
    # CTID, HOSTNAME, STATE 추출
    CTID=$(echo "$container" | awk '{print $1}')
    STATE=$(echo "$container" | awk '{print $2}')
    HOSTNAME=$(echo "$container" | awk '{print $3}')
    echo "$counter. ${HOSTNAME:-N/A} ($CTID) - ${STATE:-unknown}"
    counter=$((counter + 1))
done

# 사용자 입력받기
while true; do
    echo -n "접속할 컨테이너 번호를 입력하세요 (1-${#containers[@]}): "
    read -r selection
    if [[ $selection =~ ^[0-9]+$ ]] && [[ $selection -gt 0 && $selection -le ${#containers[@]} ]]; then
        CTID=$(echo "${containers[$((selection - 1))]}" | awk '{print $1}')
        STATE=$(echo "${containers[$((selection - 1))]}" | awk '{print $2}')
        if [[ $STATE != "running" ]]; then
            echo "컨테이너 $CTID가 실행 중이 아닙니다. 실행 후 접속하시겠습니까? (y/n): "
            read -r confirm
            if [[ $confirm == "y" ]]; then
                pct start "$CTID"
                echo "컨테이너 $CTID를 시작했습니다."
            else
                echo "접속을 취소합니다."
                exit 0
            fi
        fi
        echo "컨테이너 $CTID에 접속 중..."
        echo "$(date): 사용자 $(whoami) - 컨테이너 $CTID에 접속" >> /var/log/lxc_access.log
        pct enter "$CTID"
        break
    else
        echo "잘못된 입력입니다. 다시 시도하세요."
    fi
done