#!/bin/bash

# CSV 파일의 경로
file_csv=/home/ubuntu/ACG/Crontab/CRONTAB_PUSH_DIR.csv
# CSV 파일을 읽어 들입니다.
while read line; do
    cd "$line"
    expect_file="${line}/LNK_EXP_TRIGGER_PUSH.exp" #디렉토리 PULL & PUSH
    expect $expect_file
    expect_file="${line}/LNK_EXP_CALL_CLEAR_DIR.sh" #디렉토리 무결성 검사
    bash $expect_file
done <"$file_csv"
