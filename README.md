# ACG_CLIENT
ACG 서비스에 가입한 유저들의 CSV데이터를 자동으로 커밋해주는 클라이언트 프로그램

유저데이터 및 토큰정보 삭제된 전체공개용 코드임

 ### [[https://prod.hyunn.shop/]]

### DB 정보
1️⃣ **USER_INFO** : `/home/ubuntu/ACG/users_2023-11-03-07-41-31.csv`
> 스프링 서버에 csv 데이터 요청할때마다 데이터 변경
> /home/ubuntu/ACG/requestCSV.sh 실행

2️⃣ **PUSH_INFO** : `/home/ubuntu/ACG/Crontab/CRONTAB_PUSH_DIR.csv`
> 다음 프로세스 실행 시 변경됨
> `/home/ubuntu/ACG/MASTER_CALL_MKDIR.sh`
> `/home/ubuntu/ACG/dummy/EXP_CALL_CHECK_TRUE_CSV.sh` (사용되지 않음)

---

### crontab등록 프로세스

1. >/home/ubuntu/ACG/requestCSV.sh
   - spring 서버에 유저 데이터 요청
2. >`/home/ubuntu/ACG/MASTER_CALL_MKDIR.sh`
    - 신규 가입자 디렉토리 생성 (**USER_INFO** 의 `ID` 가 디렉토리명)
    - 이미 존재하는 유저 데이터라면 디렉토리 생성은 생략
    - `main`의 **EXP_CALL_MKDIR**에 이미 **CSV CHECK** 함께 수행됨
      - **USER_INFO** 의 status가 TRUE 인 경우에만, **PUSH_INFO** 업데이트
3. > `/home/ubuntu/ACG/MASTER_CALL_PUSH.sh`
   - 각 유저 디렉토리의 `LNK_EXP_TRIGGER_PUSH.exp` 를 실행시켜줌.
   - 각 유저 디렉토리의 README.md 를 업데이트 해줌


</br>crontab 정보
```sehll
# m h  dom mon dow   command
50 23 * * * /bin/bash /home/ubuntu/ACG/requestCSV.sh
55 23 * * * /bin/bash /home/ubuntu/ACG/MASTER_CALL_MKDIR.sh
0 */12 * * * /bin/bash /home/ubuntu/ACG/MASTER_CALL_PUSH.sh
```

---

### 항상 실행되어있는 데몬
1. `/home/ubuntu/ACG/MASTER_CALL_COMPARE_EXP.sh`
   - ~/ACG/CLINET 에 .exp 실행파일들은, 수정을 용이하게 하기 위해, 각 유저 디렉토리에 소프트링크 방식으로 바로가기를 생성함.
   - 이때문에 어떤 유저가 링크된 .exp 파일을 수정하면, 원본 데이터도 수정됨
   - 그런 이유로 백업본을 만들어, 데이터 변경이 감지되었을때, 원본 코드를 덮어써 코드를 복구함.

### 디렉토리 구조
```shell
/root
├── ACG
│   ├── CLIENT
│   │   ├── Backup #원본 EXP 파일
│   │   └── Src # 참조용 EXP 파일
│   ├── Crontab #Crontab csv 및 코드 존재
│   ├── dummy #미사용 데이터
│   │   ├── ReadCSV
│   │   └── data
│   │       └── cron_users
│   └── tcp_ip
└── ACG_USER
   └── <ID index>
       └── ACG_repo
```
