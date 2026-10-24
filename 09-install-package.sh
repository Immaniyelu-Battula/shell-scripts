#!/bin/bash
user_id=$(id -u)

if [ $user_id -ne 0 ]; then
echo "Please run with root access"
exit 1
fi 

dnf list install mysql 

if [ $? -eq 0 ]; then

echo "Mysql already installed ..Skipping mysql installtion"

else 

dnf install mysql -y

if [ $? -ne 0 ]; then

echo " mysql installation failed"

else

echo "Mysql installtion success"
fi
fi
