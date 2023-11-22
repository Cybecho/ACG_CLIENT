   #!/bin/bash

   file_to_monitor="/mnt/c/ubuntu/ACG/data/main_crontab.txt"
   previous_hash=""
   log_file="./data/cron_update.log"

   while true; do
       current_hash=$(md5sum "$file_to_monitor" | awk '{print $1}')
       if [ "$current_hash" != "$previous_hash" ]; then
           crontab "$file_to_monitor"
           update_time=$(date "+%Y-%m-%d %H:%M:%S")
           echo "Main Crontab updated from $file_to_monitor at $update_time"
           echo "Main Crontab updated at $update_time" >> "$log_file"
           previous_hash="$current_hash"
       fi
       sleep 60  # 1분마다 파일의 해시값을 확인
   done