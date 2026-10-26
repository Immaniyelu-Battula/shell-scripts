#!/bin/bash
LOGDIR=/var/log/roboshop
sudo mkdir -p $LOGDIR
sudo chown -R ec2-user:ec2-user $LOGDIR
sudo chmod -R 755 $LOGDIR
LOGFILE="$LOGDIR/$0.log"
user_id=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
O="\e[34m"
N="\e[0m"
scripts_dir="/home/ec2-user/shell-scripts/roboshop-v1"
timestamp=$(date +%y-%m-%d-%H-%m)

if [ $user_id -ne 0 ]; then
echo -e "$R ..Please run with root user $N" | tee -a $LOGFILE
exit 1
fi

validate(){
    if [ $1 -ne 0 ]; then
    echo -e "$timestamp [INFO] $2 ..$R Failure $N" | tee -a $LOGFILE
    exit 1
    else
    echo -e "$timestamp [INFO] $2 .. $G Sucess..$N" | tee -a $LOGFILE
    fi
}

echo "script start time $timestamp"

dnf module disable nodejs -y
dnf module enable nodejs:20 -y
validate $? "enable nodejs:20 version"
dnf install nodejs -y
validate $? "install nodejs"
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
rm -rf /app
mkdir /app 
validate $? "delete & create /app directory"
curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
cd /app 
unzip /tmp/user.zip
validate $? "download & extract user folder"
cd /app 
npm install 
validate $? "compile nodejs"
cp $scripts_dir/user.service /etc/systemd/system/user.service
systemctl daemon-reload
validate $? "restart the user services"
systemctl enable user 
systemctl start user
validate $? "enable & start user services"