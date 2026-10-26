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

dnf install maven -y &>> $LOGFILE
validate $? "install maven"
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGFILE
rm /app &>> $LOGFILE
mkdir /app &>> $LOGFILE
validate $? "add user roboshop & add /app folder"
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> $LOGFILE
cd /app &>> $LOGFILE
unzip /tmp/shipping.zip &>> $LOGFILE
validate $? "download & extract shipping.zip file"
cd /app &>> $LOGFILE
mvn clean package &>> $LOGFILE
mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
validate $? "compile maven and create artifact"
systemctl daemon-reload &>> $LOGFILE
validate $? "reload systemctl services"
systemctl enable shipping &>> $LOGFILE
systemctl start shipping &>> $LOGFILE
validate $? "enable and start shipping service"
dnf install mysql -y &>> $LOGFILE
validate $? "install mysql clinet software"
mysql -h mysql.immaniyelu.shop -uroot -pRoboShop@1 < /app/db/schema.sql &>> $LOGFILE
mysql -h mysql.immaniyelu.shop -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LOGFILE
mysql -h mysql.immaniyelu.shop -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LOGFILE
validate $? "load data"
systemctl restart shipping &>> $LOGFILE
validate $? "restart shipping services"