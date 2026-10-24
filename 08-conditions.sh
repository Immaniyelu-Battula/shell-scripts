#!/bin/bash

echo "Please enter the marks?"
read marks
if [ $marks -lt 33 ]; then
echo "Sorry! you are failed..please try next time"
elif [ $marks -lt 50 ]; then
echo "Congartulations ! you have passed in 3 rd class"
elif [ $marks -lt 60 ]; then
echo "Congratulations ! You have passed 2 nd class"
elif [ $marks -lt 75 ]; then
echo "Congrats !! You have achived 1 st class..Nice work"
else 
echo "Excellent work ..You got good marks"
fi