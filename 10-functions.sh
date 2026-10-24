#!/bin/bash

validate(){
if [ $? - ne 0 ]; then
echo "command is failed"
else
echo " command is success"
fi
}

date =$(date)

validate 