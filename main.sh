#!/bin/bash

# csv 파일의 디렉토리를 지정합니다.
USER_DATA_DIR="/home/ubuntu/ACG"
USER_DATA=$(find "$USER_DATA_DIR" -name "user_*" -type f) #날짜는 변경될 것이기 때문do 파일 앞부분만 이름을 맞춰줍니다
# REPO 이름 전역 변수 선언
REPO="ACG_REPO"
export REPO

TARGET_DIR="/home/ubuntu/ACG_USER"
export TARGET_DIR

#~CSV EXPORT 함수
function GET_USER_DATA() {
    # 매개변수를 받아옵니다.
    INPUT="$1"
    OUTPUT_COL="$2"
    # ID,user_ID,user_Name, user_Email, user_Token,user_Repo,status
    # 0: user_repo
    # 1: id
    # 3: username
    # 5 : token
    # 4 : email

    case $OUTPUT_COL in
    0)
        while IFS=',' read ID user_ID user_Name user_Email user_Token user_Repo status; do
            if [ "${INPUT}" == "${ID}" ]; then
                echo "${user_Repo}"
                return # 함수 종료
            fi
        done <${USER_DATA}
        ;;
    1)
        while IFS=',' read ID user_ID user_Name user_Email user_Token user_Repo status; do
            if [ "${INPUT}" == "${ID}" ]; then
                echo "${ID}"
                return # 함수 종료
            fi
        done <${USER_DATA}
        ;;
    2)
        while IFS=',' read ID user_ID user_Name user_Email user_Token user_Repo status; do
            if [ "${INPUT}" == "${ID}" ]; then
                echo "${user_ID}"
                return # 함수 종료
            fi
        done <${USER_DATA}
        ;;
    3)
        while IFS=',' read ID user_ID user_Name user_Email user_Token user_Repo status; do
            if [ "${INPUT}" == "${ID}" ]; then
                echo "${user_Token}"
                return # 함수 종료
            fi
        done <${USER_DATA}
        ;;
    4)
        while IFS=',' read ID user_ID user_Name user_Email user_Token user_Repo status; do
            if [ "${INPUT}" == "${ID}" ]; then
                echo "${user_Email}"
                return # 함수 종료
            fi
        done <${USER_DATA}
        ;;
    *)
        echo $'유효한 형태 : GET_USER_DATA <id> <select data>\n'
        echo $'1: id\n# 3: username\n# 5 : token\n# 4 : email\n'
        return 1 # 함수 종료
        ;;
    esac
}
# 함수 호출 방법
#RESULT=$(GET_USER_DATA 3 2)
#echo $RESULT

#~CSV에 포함된 ID 전체 디렉토리를 생성시킵니다
#?처음 가입 후 데이터에 추가되었을때만 실행됩니다
function CSV_TO_DIR() {
    # 폴더를 생성할 디렉토리
    TARGET_DIR="/home/ubuntu/ACG_USER"

    # CSV 파일을 읽어 들입니다.
    # 첫 번째 행은 제외합니다.
    # 각 행은 배열로 저장됩니다.
    # IFS를 쉼표로 설정하여 필드를 쉼표로 구분하도록 합니다.
    IFS=,
    CSV_DATA=$(cat ${USER_DATA} | tail -n +2 | cut -d, -f1)

    # 반복문에서 IFS를 원래 값으로 되돌리기 위해 이전 IFS 값을 백업합니다.
    OLD_IFS=$IFS

    # 폴더를 생성합니다.
    # 이미 존재하는 폴더라면 생성을 생략합니다
    #for row in ${CSV_DATA}; do #!기존 코드
    echo "${CSV_DATA}" | while read -r row; do #!수정 코드
        #echo "${row}" | cut -d, -f1
        IFS=,
        ID=$(echo "${row}")
        if [ ! -d "${TARGET_DIR}/${ID}" ]; then #처음 추가된 경우에만
            DIR="${TARGET_DIR}/${ID}/${REPO}"
            mkdir -p ${TARGET_DIR}/${ID}/${REPO}
            ln -sf /home/ubuntu/ACG/CLIENT/Src/EXP_TRIGGER_CLONE.exp ${DIR}/LNK_EXP_TRIGGER_CLONE.exp
            ln -sf /home/ubuntu/ACG/CLIENT/Src/EXP_TRIGGER_PUSH.exp ${DIR}/LNK_EXP_TRIGGER_PUSH.exp
            ln -sf /home/ubuntu/ACG/CLIENT/Src/EXP_CALL_CLEAR_DIR.sh ${DIR}/LNK_EXP_CALL_CLEAR_DIR.sh
            cd ${DIR}
            pwd
            #?echo "${DIR}" >>~/ACG/Crontab/CRONTAB_PUSH_DIR.csv #CRONTAB 디렉토리에 등록
            # expect 코드를 포함하는 파일을 지정하고 실행함
            #! GIT CLONE
            expect_file="${DIR}/LNK_EXP_TRIGGER_CLONE.exp"
            expect $expect_file
            rm ${DIR}/LNK_EXP_TRIGGER_CLONE.exp #필요 없어진 CLONE 파일은 삭제 (처음에만 사용)
            #! GIT PUSH 2023/11/11 비활성화 / 사유: 이거 실행하면 false인 놈들도 nall이라는 git저장소가 생성됨
            #! 따로 MASTER_CALL_PUSH로 push한다
            #~expect_file="${DIR}/LNK_EXP_TRIGGER_PUSH.exp" #첫 PUSH
            #~expect $expect_file
        fi
    done
    # 반복문 종료 후 IFS를 이전 값으로 되돌립니다.
    IFS=$OLD_IFS

    #CSV_CHECK_TRUE_CSV #FALSE 인 계정은 push index 에서 제외합니다``
}
#echo $(CSV_TO_DIR)

#~TRUE FALSE 로 CSV PUSH 컨트롤하기
#? 누군가 탈퇴하거나 비활성화 했을때!
#? CSV를 하루에 한번 불러오고나서, status가 false로 바뀐 데이터들을 처리해준다
function CSV_CHECK_TRUE_CSV() {
    # 폴더를 생성할 디렉토리
    TARGET_DIR="/home/ubuntu/ACG_USER"

    # CSV 파일을 읽어 들입니다.
    # 첫 번째 행은 제외합니다.
    # 각 행은 배열로 저장됩니다.
    CSV_DATA=$(cat ${USER_DATA} | tail -n +2)

    # 임시 파일 생성
    TMP_FILE=$(mktemp)

    #for row in ${CSV_DATA}; do #!기존 코드
    echo "${CSV_DATA}" | while read -r row; do #!수정 코드
        # CSV 데이터에서 status 값을 가져옵니다.
        ID=$(echo $row | cut -d ',' -f 1)
        status=$(echo $row | cut -d ',' -f 7)
        echo "${status} ${ID}"
        DIR="${TARGET_DIR}/${ID}/${REPO}"
        # status 값이 False가 아닌 경우만 임시 파일에 추가
        if [ "$status" = "true" ]; then
            echo "${DIR}" >>"$TMP_FILE"
            #?echo "${DIR}/LNK_EXP_TRIGGER_PUSH.exp" >>"$TMP_FILE"
        fi
    done

    # 임시 파일을 원래 파일로 복사하여 덮어쓰기
    mv "$TMP_FILE" ~/ACG/Crontab/CRONTAB_PUSH_DIR.csv
}

#CSV_CHECK_TRUE_CSV

#~상위 디렉토리명 추출하는 함수
function EXPORT_ID_DIR() {
    # 현재 디렉토리의 상위 폴더의 이름을 가져옵니다.
    top_dir=$(dirname $(pwd))
    # 두번째 디렉토리명을 가지고 오고 싶으면 다음처럼 코드를 작성하시오
    #top_dir=$(readlink -f $(dirname $(dirname $(pwd))))

    # 변수에 해당 이름을 설정합니다.
    top_dir_name=${top_dir##*/}

    # 변수의 내용을 출력합니다.
    echo "${top_dir_name}"
    return
}
# 함수 호출 방법
#DIR=$(EXPORT_ID_DIR)
#RESULT=$(GET_USER_DATA $DIR 3)
#echo $DIR $RESULT

#~디렉토리 무결성 유지 ㅏ함수
#? 반드시 CLONE_GIT_PUSH 실행 후 생성해야합니다. PULL이 된 후에 실행되어야 하기 떄문입니다.
function CLEAR_DIR() {
    find . -type f ! -name "LNK_EXP_TRIGGER_PUSH.exp" ! -name "README.md" ! -name "LNK_EXP_CALL_CLEAR_DIR.sh" ! -name "error.log" -exec rm -f {} +
}

#~Spring 서버에 CSV 최신화
#? git push와 함께 사용하시오
function post_CSV() {
    cat <<EOF
    {
        "id": $1, 
        "userId": "$2", 
        "userEmail": "$3", 
        "updateTime": "$4", 
        "error": $5
    }
EOF
}
# 사용 에시
# curl -X POST -H "Content-Type: application/json" -H "Token: <TOKEN>" -d "$(post_CSV $id $userId $userEmail $updateTime $error)" https://prod.hyunn.shop/user/update

#~git_push 함수
function CLONE_GIT_PUSH() {
    # 매개변수를 받아옵니다.
    ID="$1"
    REPO_NAME=$(GET_USER_DATA $ID 0)
    GITHUB_USERNAME=$(GET_USER_DATA $ID 2)
    GITHUB_TOKEN=$(GET_USER_DATA $ID 3)
    GITHUB_EMAIL=$(GET_USER_DATA $ID 4)
    updateTime="$(date +"%Y-%m-%d-%H-%M-%S")"
    error="${updateTime}"
    echo "${GITHUB_USERNAME} 계정 Auto Commit"
    # ID,user_ID,user_Name, user_Email, user_Token,user_Repo,status
    # 1: id
    # 2: username
    # 3 : token
    # 4 : email

    # Repository name

    # Commit 대표인
    git config --global user.name "$GITHUB_USERNAME"
    git config --global user.email "$GITHUB_EMAIL"

    # Add, commit, and push the file to the newly created repository
    git pull #유저가 따로 디렉토리를 수정헀을수도 있으니까
    git init
    touch README.md
    echo "$(date) $(echo -e "<br/>")" >>./README.md
    git add ./*.md
    git commit -m "By ACG Automated commit $(date)"
    git remote add origin https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$REPO_NAME.git
    git remote set-url origin https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$REPO_NAME.git
    git branch -M master
    git push -f origin master 2>&1 | tee ./error.log #2>&1은 stderr을 stdout으로 리디렉션하는 명령어입니다.

    #!에러 처리
    # error.log 파일에서 error 문구를 찾습니다.
    # error_log 변수가 null이 아닌 경우, error_log 전체를 $error 변수에 넣습니다.
    error_log=$(cat ./error.log | grep -o "error" | tr '\n' '|')
    if [[ -n $error_log ]]; then
        error=$error_log
    else
        #error=$(echo "${updateTime}")
        error=null
    fi
    #! json POST METHOD를 통한 Spring서버 통신
    #curl -X POST -H "Content-Type: application/json" -H "Token: <TOKEN>" -d "{"id": "${ID}", "userId": "${GITHUB_USERNAME}", "userEmail": "${GITHUB_EMAIL}", "updateTime": "${updateTime}", "error": null}" https://prod.hyunn.shop/user/update
    curl -X POST -H "Content-Type: application/json" -H "Token: <TOKEN>" -d "$(post_CSV $ID $GITHUB_USERNAME $GITHUB_EMAIL $updateTime $error)" https://prod.hyunn.shop/user/update
}

#~git_clone 함수
function CLONE_GIT_REPO() {
    # 매개변수를 받아옵니다.
    ID="$1"

    REPO_NAME=$(GET_USER_DATA $ID 0)
    GITHUB_USERNAME=$(GET_USER_DATA $ID 2)
    GITHUB_TOKEN=$(GET_USER_DATA $ID 3)
    GITHUB_EMAIL=$(GET_USER_DATA $ID 4)
    echo "현재 유저네임 및 토큰"
    echo "${GITHUB_USERNAME}"
    echo "${GITHUB_TOKEN}"
    # ID,user_ID,user_Name, user_Email, user_Token,user_Repo,status
    # 1: id
    # 2: username
    # 3 : token
    # 4 : email

    # Commit 대표인
    git config --global user.name "$GITHUB_USERNAME"
    git config --global user.email "$GITHUB_EMAIL"

    # GITHUB 저장소 생성 using the PAT
    # 근데 이거 SPRING SERVER 에서 git action으로 이미 생성해주네... 고로 ubuntu 서버에서는 불필요한 작업임
    curl -u "$GITHUB_USERNAME:$GITHUB_TOKEN" https://api.github.com/user/repos -d "{\"name\":\"$REPO_NAME\"}"

    # Add, commit, and push the file to the newly created repository
    git init
    touch README.md
    git add ./*.md
    git commit -m "By ACG Automated commit $(date)"
    git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    git remote set-url origin https://$GITHUB_USERNAME@github.com/$GITHUB_USERNAME/$REPO_NAME.git
    git branch -M master
    git push -u origin master
}
# 함수 호출 방법
#CLONE_GIT_REPO 0003

#CLONE_GIT_REPO $(EXPORT_ID_DIR)

####테스트 코드####
#DIR=$(EXPORT_ID_DIR)
#echo $DIR

#RESULT=$(GET_USER_DATA $DIR 3)
#RESULT=$(GET_USER_DATA $(EXPORT_ID_DIR) 2)
#echo $RESULT

#CLONE_GIT_REPO $DIR

#~git_reclone 함수
#! 023/11/11 비활성화 / 사유: 이거 굳이 안써도 기존에 존재하는 저장소라면 MASTER_MKDIR에서 set url 하면서 권한 얻게됨
function RECLONE_GIT_REPO() {
    # 매개변수를 받아옵니다.
    ID="$1"
    DIR="${TARGET_DIR}/${ID}/${REPO}"
    REPO_NAME=$(GET_USER_DATA $ID 0)
    GITHUB_USERNAME=$(GET_USER_DATA $ID 2)
    GITHUB_TOKEN=$(GET_USER_DATA $ID 3)
    GITHUB_EMAIL=$(GET_USER_DATA $ID 4)
    # ID,user_ID,user_Name, user_Email, user_Token,user_Repo,status
    # 1: id
    # 2: username
    # 3 : token
    # 4 : email
    echo "다시 clone"

    #! 다시 clone
    cd "${TARGET_DIR}/${ID}"
    rm -rf "${DIR}"
    git clone https://github.com/$GITHUB_USERNAME/$REPO_NAME.git "${REPO}"

    # Add, commit, and push the file to the newly created repository
    cd "${DIR}"
    git init
    # Commit 대표인
    git config --global user.name "$GITHUB_USERNAME"
    git config --global user.email "$GITHUB_EMAIL"

    ln -sf /home/ubuntu/ACG/CLIENT/Src/EXP_TRIGGER_PUSH.exp ${DIR}/LNK_EXP_TRIGGER_PUSH.exp
    ln -sf /home/ubuntu/ACG/CLIENT/Src/EXP_CALL_CLEAR_DIR.sh ${DIR}/LNK_EXP_CALL_CLEAR_DIR.sh
    touch README.md
    git add ./*.md
    git commit -m "By ACG Automated commit $(date)"
    git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    git remote set-url origin https://$GITHUB_USERNAME@github.com/$GITHUB_USERNAME/$REPO_NAME.git
    git branch -M master
    git push -u origin master
}
#RECLONE_GIT_REPO $(EXPORT_ID_DIR)
