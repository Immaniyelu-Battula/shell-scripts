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

dnf install python3 gcc python3-devel -y &>> $LOGFILE
validate $? "Install python libraries"

if [ "user" = "roboshop" ];then 
echo "usesr already exists"
else
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGFILE
fi
validate $? " adding roboshop user"
rm -rf /app &>> $LOGFILE
mkdir /app &>> $LOGFILE
validate $? "deleting & creating /app folder"
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>> $LOGFILE
cd /app  &>> $LOGFILE
unzip /tmp/payment.zip &>> $LOGFILE
validate $? "downloading & extracting the payment.zip"
cd /app &>> $LOGFILE
pip3 install -r requirements.txt &>> $LOGFILE
validate $? "compile python and create artifact"
cp payment.service /etc/systemd/system/payment.service &>> $LOGFILE
systemctl daemon-reload &>> $LOGFILE

validate $? "reload systemctl services"
systemctl enable payment &>> $LOGFILE
systemctl start payment  &>> $LOGFILE

validate $? "start & enable payment services"