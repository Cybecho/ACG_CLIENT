#!/bin/bash

# csv 파일의 디렉토리를 지정합니다.
DATA_DIR="./../ACG_USERDATA.csv"

function GET_USER_DATA() {
    # 매개변수를 받아옵니다.
    ID="$1"
    OUTPUT_COL="$2"
    # 1: id
    # 2: username
    # 3 : token
    # 4 : email

    case $OUTPUT_COL in
    1)
        while IFS=',' read id username token email; do
            if [ "${id}" == "${ID}" ]; then
                echo "${id}"
                return # 함수 종료
            fi
        done <${DATA_DIR}
        ;;
    2)
        while IFS=',' read id username token email; do
            if [ "${id}" == "${ID}" ]; then
                echo "${username}"
                return # 함수 종료
            fi
        done <${DATA_DIR}
        ;;
    3)
        while IFS=',' read id username token email; do
            if [ "${id}" == "${ID}" ]; then
                echo "${token}"
                return # 함수 종료
            fi
        done <${DATA_DIR}
        ;;
    *)
        echo -e "유효한 형태 : GET_USER_DATA <id> <select data>"
        echo -e "select data 는 다음에서 고르시오\n 1 : id \n 2 : username \n 3 : token  \n 4 : email"
        return 1 # 함수 종료
        ;;
    esac
}

# 함수 호출 및 결과 캡처
#RESULT=$(GET_USER_DATA 0001 3)
#echo $RESULT
