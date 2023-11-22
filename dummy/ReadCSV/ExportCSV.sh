#!/bin/bash

source ./ReadCSV.sh
# 1: id
# 2: username
# 3 : token
# 4 : email

# ReadCSV.sh 스크립트 안에 GET_USER_DATA 함수를 불러옵니다
RESULT=$(GET_USER_DATA 0003 3)

# ReadCSV.sh의 결과값을 출력합니다.
echo ${RESULT}
