#!/bin/bash

# 백업할 파일의 경로
file_src=/home/ubuntu/ACG/CLIENT/Src/EXP_TRIGGER_PUSH.exp
file_backup=/home/ubuntu/ACG/CLIENT/Backup/Backup_EXP_TRIGGER_PUSH.exp

# 백업 파일이 존재하지 않으면 생성
if [ ! -f "$file_backup" ]; then
    cp "$file_src" "$file_backup"
fi

# 주기적으로 코드 수정 감지
while true; do
    # 현재 파일의 MD5 해시값을 구한다.
    md5_src=$(md5sum "$file_src" | awk '{print $1}')

    # 백업 파일의 MD5 해시값을 구한다.
    md5_backup=$(md5sum "$file_backup" | awk '{print $1}')

    # 두 해시값이 다르면 백업한다.
    if [ "$md5_src" != "$md5_backup" ]; then
        cp "$file_backup" "$file_src"
        echo "${file_src} 변경 감지! 원본으로 수정"
    fi

    # 10초 대기
    sleep 10
done
