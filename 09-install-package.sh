#!/bin/bash
user_id=$(id -u)

if [ $user_id -ne 0 ]; then
echo "Please run with root access"
exit 1
fi 
echo "Installing packages"

dnf install nginxx -y
dnf install mysql -y

if [ $? -eq 0 ]; then

echo "package installation completed.."

else

echo "Package installation failed..please retry.."
fi