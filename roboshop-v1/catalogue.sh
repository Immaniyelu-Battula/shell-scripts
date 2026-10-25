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

echo "script dir : $scripts_dir"


dnf module disable nodejs -y &>> $LOGFILE
validate $? "Disabling old Nodejs"

dnf module enable nodejs:20 -y &>> $LOGFILE
validate $? "enable version 20 Nodejs"
dnf install nodejs -y &>> $LOGFILE
validate $? "Isnstalling version 20 Nodejs"
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGFILE
rm -rf /app &>> $LOGFILE
mkdir /app 
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOGFILE
cd /app 
rm -rf /tmp/catalogue.zip &>> $LOGFILE
unzip /tmp/catalogue.zip &>> $LOGFILE
validate $? "downloading & unzipping catalogue.zip"
cd /app 
npm install &>> $LOGFILE 
validate $? "compiling nodejs"
cp catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE 
validate $? "copy the catalogue file"
systemctl daemon-reload &>> $LOGFILE 
validate $? "restaring catalogue daemon"
systemctl enable catalogue &>> $LOGFILE
systemctl start catalogue &>> $LOGFILE
validate $? "restarting the  catalogue"

dnf install mongodb-mongosh -y &>> $LOGFILE


#mongosh --host mongodb.immaniyelu.shop </app/db/master-data.js
