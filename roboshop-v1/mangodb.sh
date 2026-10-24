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

cp "$scripts_dir/mongo.repo /etc/yum.repos.d/mongo.repo  &>> $LOGFILE
validate $? "Copying the mongo repo file"

dnf install mongodb-org -y &>> $LOGFILE

validate $? "Instaling the Mongodb binaries"

systemctl enable mongod &>> $LOGFILE
validate $? "Enabling the mongod"
systemctl start mongod  &>> $LOGFILE
validate $? "Starting the mongod"
sed -i  's%127.0.0.1%0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
#sed -i 's/127\.0\.0\.1/0.0.0.0/g' /etc/mongod.conf &>> "$LOGFILE"
validate $? "changing the mongod.conf file"

systemctl restart mongod &>> $LOGFILE

validate $? "Restarting the mongod demon"

