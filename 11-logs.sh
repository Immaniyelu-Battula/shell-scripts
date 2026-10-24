#!/bin/bash
user_id=$(id -u)
logdir=/var/log/shell-scripts/
logfile="$logdir/$0.log"
dnf install mysql &>> $logfile
dnf install nginx &>> $logfile


