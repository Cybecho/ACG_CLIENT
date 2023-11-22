#!/bin/bash

main_crontab="./data/main_crontab.txt"
sub_crontab_dir="/mnt/c/ubuntu/ACG/data/cron_users"  # 서브 크론탭 파일이 있는 디렉토리
log_file="./data/cron_update.log"

# 서브 크론탭 파일을 모두 합칩니다. 줄바꿈 포함.
for file in "$sub_crontab_dir"/*.txt; do
  cat "$file" >> "$main_crontab.temp"
  echo -e "\n" >> "$main_crontab.temp"  # 각 파일 후에 빈 줄(줄바꿈) 추가
done

# 기존 main_crontab 파일과 새로 생성한 main_crontab.temp 파일을 비교합니다.
if cmp -s "$main_crontab" "$main_crontab.temp"; then
  echo "No changes in sub_crontab files."
else
  # 변경된 경우 main_crontab 파일을 업데이트합니다.
  mv "$main_crontab.temp" "$main_crontab"
  crontab "$main_crontab"
  update_time=$(date "+%Y-%m-%d %H:%M:%S")
  echo "Sub Crontab updated at $update_time." >> "$log_file"
fi