#!/bin/bash

validate(){
if [ $? -ne 0 ]; then
echo "command is failed"
else
echo "$seconds command is success"
fi
}

seconds=$(date +%s)
echo "total seconds $seconds seconds"
validate 