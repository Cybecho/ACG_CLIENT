#!/bin/bash

source /home/ubuntu/ACG/main.sh

CSV_CHECK_TRUE_CSV #FALSE 인 계정은 push index 에서 제외합니다
CSV_TO_DIR         #git push용 디렉토리를 생성합니다
