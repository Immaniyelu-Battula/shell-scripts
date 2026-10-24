#!/bin/bash
user_id=$(id -u)
logdir=/var/log/shell-scripts/
logfile="$logdir/$0.log"

validate(){
 if [ $2 -ne 0]; then
    echo "Installing $1 is failed"
    exit 1
    else
    echo "Installing $1 is sucess..."
 fi
}

for package in $@
do
dnf list install $package

if [ $? -ne 0];then
dnf install $package -y 
validate $package $?
else
echo "$package already installed."
fi
done
