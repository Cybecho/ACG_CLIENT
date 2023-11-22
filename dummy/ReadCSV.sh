#!/bin/bash

# csv 파일의 디렉토리를 지정합니다.
DATA_DIR="./../ACG_USERDATA.csv"
INPUT_NAME="HelloZOOO"
OUTPUT_COL=2
# 1: id
# 2: username
# 3 : token
# 4 : email

case $OUTPUT_COL in
1)
    while IFS=',' read id username token email; do
        if [ "${username}" == "${INPUT_NAME}" ]; then
            echo "${id}"
        fi
    done <${DATA_DIR}
    ;;
2)
    while IFS=',' read id username token email; do
        if [ "${username}" == "${INPUT_NAME}" ]; then
            echo "${username}"
        fi
    done <${DATA_DIR}
    ;;
3)
    while IFS=',' read id username token email; do
        if [ "${username}" == "${INPUT_NAME}" ]; then
            echo "${token}"
        fi
    done <${DATA_DIR}
    ;;
*)
    echo "# 1: username # 2 : token # 3 : email"
    ;;
esac
