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


dnf module disable nginx -y &>> $LOGFILE
dnf module enable nginx:1.24 -y &>> $LOGFILE
dnf install nginx -y &>> $LOGFILE
validate $? "Installing nginx"
systemctl enable nginx &>> $LOGFILE
systemctl start nginx &>> $LOGFILE 
validate $? "starting nginx"
rm -rf /usr/share/nginx/html/* &>> $LOGFILE

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOGFILE
validate $? "downloading the artifact"
cd /usr/share/nginx/html &>> $LOGFILE
unzip /tmp/frontend.zip  &>> $LOGFILE 
validate $? "unzip the artifact"
cp $scripts_dir/nginx.conf /etc/nginx/nginx.conf &>> $LOGFILE
validate $? "copying the nginx conf file"
systemctl restart nginx  &>> $LOGFILE

validate $? "restarting nginx"