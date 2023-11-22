#!/bin/bash

source /home/ubuntu/ACG/main.sh

RESULT=$(GET_USER_DATA $(EXPORT_ID_DIR) 4)

echo $RESULT

# ID,user_ID,user_Name, user_Email, user_Token,user_Repo,status
# 0: user_repo
# 1: id
# 3: username
# 5 : token
# 4 : email
