#!/bin/bash
# 현재 날짜를 가져옵니다.
today=$(date +"%Y-%m-%d-%H-%M-%S")

cd /home/ubuntu/ACG
mv ./*.csv ~/latest_data

# Curl 명령을 실행합니다.
curl -X GET -H "Token: <TOKEN>" https://prod.hyunn.shop/user/list/csv -o user_$today.csv

source /home/ubuntu/ACG/main.sh
CSV_CHECK_TRUE_CSV
