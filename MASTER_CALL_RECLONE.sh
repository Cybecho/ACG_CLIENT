#!/bin/bash

# CSV 파일의 경로
file_csv=/home/ubuntu/ACG/Crontab/CRONTAB_PUSH_DIR.csv
# CSV 파일을 읽어 들입니다.
while read line; do
    cd "$line"
    mkdir "../RESET"
    cd ".."
    ln -sf /home/ubuntu/ACG/CLIENT/Backup/Backup_EXP_TRIGGER_RECLONE.exp ./RESET/LNK_EXP_TRIGGER_RECLONE.exp
    expect_file="./RESET/LNK_EXP_TRIGGER_RECLONE.exp" #디렉토리 PULL & PUSH
    expect $expect_file
done <"$file_csv"
