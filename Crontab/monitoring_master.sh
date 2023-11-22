#!/bin/bash

main_crontab="./data/main_crontab.txt"
sub_crontab_dir="/mnt/c/ubuntu/ACG/data/cron_users"
log_file="./data/cron_update.log"

# 이전 해시 값을 초기화합니다.
main_prev_hash=""
sub_prev_hash=""

while true; do
  # 현재 main_crontab 파일의 해시 값을 계산합니다.
  main_current_hash=$(md5sum "$main_crontab" | awk '{print $1}')

  # 현재 서브 크론탭 파일들의 해시 값을 계산합니다.
  sub_current_hash=$(find "$sub_crontab_dir" -type f -exec md5sum {} \; | sort | md5sum | awk '{print $1}')
  /home/ubuntu/ACG/Crontab
  # main_crontab 파일이 변경된 경우에만 업데이트합니다.
  if [ "$main_current_hash" != "$main_prev_hash" ]; then
    crontab "$main_crontab"
    update_time=$(date "+%Y-%m-%d %H:%M:%S")
    echo "Main Crontab updated from $main_crontab at $update_time"
    echo "Main Crontab updated at $update_time" >>"$log_file"
    main_prev_hash="$main_current_hash"
  fi

  # 서브 크론탭 파일이 변경된 경우에만 업데이트합니다.
  if [ "$sub_current_hash" != "$sub_prev_hash" ]; then
    for file in "$sub_crontab_dir"/*.txt; do
      cat "$file" >>"$main_crontab.temp"
      echo -e "\n" >>"$main_crontab.temp" # 각 파일 후에 빈 줄(줄바꿈) 추가
    done

    mv "$main_crontab.temp" "$main_crontab"
    crontab "$main_crontab"
    update_time=$(date "+%Y-%m-%d %H:%M:%S")
    echo "Sub Crontab updated at $update_time."
    echo "Sub Crontab updated at $update_time" >>"$log_file"

    # 이전 해시 값을 업데이트합니다.
    sub_prev_hash="$sub_current_hash"
  fi

  # 1분 대기 후에 다시 검사합니다.
  sleep 60
done
