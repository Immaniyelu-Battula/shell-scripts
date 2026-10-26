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

dnf module disable nodejs -y &>> $LOGFILE
dnf module enable nodejs:20 -y &>> $LOGFILE
validate $? "enable nodejs 20"
dnf install nodejs -y &>> $LOGFILE
validate $? "install nodejs 20"
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGFILE

rm -rf /app &>> $LOGFILE
mkdir /app &>> $LOGFILE

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>> $LOGFILE
validate $? "download cart zip file"
cd /app &>> $LOGFILE
unzip /tmp/cart.zip &>> $LOGFILE
validate $? "extract cart zip file"
cd /app &>> $LOGFILE
npm install &>> $LOGFILE
validate $? "compile node js objects"
cp $scripts_dir/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
systemctl daemon-reload &>> $LOGFILE

validate $? "reload systemctl services"
systemctl enable cart &>> $LOGFILE
systemctl start cart &>> $LOGFILE
validate $? "enable & start cart services"

echo "script completed time $timestamp"