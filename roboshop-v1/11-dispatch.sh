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

dnf install golang -y &>> $LOGFILE
validate $? "installing the golang"
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGFILE
validate $? "adding roboshop user"
mkdir /app &>> $LOGFILE
validate $? "deleting & creating /app folder"
curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &>> $LOGFILE
unzip /tmp/dispatch.zip &>> $LOGFILE
validate $? "download & extracting the dispatch file"

cd /app &>> $LOGFILE
go mod init dispatch &>> $LOGFILE
validate $? "initialize the dispatch "
go get &>> $LOGFILE
go build &>> $LOGFILE 
validate $? "compile the dispatch artifcat"
cp $scripts_dir/dispatch.service /etc/systemd/system/dispatch.service &>> $LOGFILE
systemctl daemon-reload &>> $LOGFILE
validate $? "reload systemctl services"
systemctl enable dispatch &>> $LOGFILE
systemctl start dispatch &>> $LOGFILE
validate $? "enable & start dispatch services"