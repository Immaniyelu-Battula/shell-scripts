#!/bin/bash
user_id=$(id -u)

if [ $user_id -ne 0 ]; then
echo "Please run with root access"
exit 1
fi 
echo "Installing packages"

dnf install httpd -y

if [ $? -ne 0 ]; then

echo "package installation failed.."
else
echo "Package installation completed successfully.."
fi
dnf install mangod -y

if [ $? -ne 0 ]; then

echo "package installation failed.."
else
echo "Package installation completed successfully.."
fi