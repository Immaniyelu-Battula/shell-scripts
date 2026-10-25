#!/bin/bash
ami_id="ami-0055977a6e828a4f4"
zone_id="Z06556651FH3Z7Y34VUG6"
domain_name="immaniyelu.shop"

if [ $1 -eq "frontend" ];then
web_instance=$(aws ec2 run-instances \
    --image-id ami-0055977a6e828a4f4 \
    --count 1 \
    --instance-type t3.micro \
    --security-groups sg-0e1875cf2c9414138,sg-0d4bda11836aaf555 \
    --subnet-id subnet-09cc0b32fa38571c7)
echo "instance is created : $web_instance"
web_ip=$(aws ec2 describe-instances \
    --instance-ids $web_instance \
    --query 'Reservations[*].Instances[*].PublicIpAddress' \
    --output text)

    echo "instance ip: $web_ip"
    else
for instance in $@
do
instance=$(aws ec2 run-instances \
    --image-id ami-0055977a6e828a4f4 \
    --count 1 \
    --instance-type t3.micro \
    --security-groups sg-0e1875cf2c9414138,sg-02e1f3f087a51c145 \
    --subnet-id subnet-0a80134e740dd411a)

ip=$(aws ec2 describe-instances \
    --instance-ids $instance \
    --query "Reservations[*].Instances[*].PrivateIpAddress" \
    --output text)
done 
fi