#!/bin/bash
ami_id="ami-0055977a6e828a4f4"
zone_id="Z06556651FH3Z7Y34VUG6"
domain_name="immaniyelu.shop"


for instance in $@
do
instance_id=$(aws ec2 run-instances \
    --image-id $ami_id \
    --count 1 \
    --instance-type t3.micro \
    --security-groups sg-0e1875cf2c9414138 \
    --subnet-id subnet-0a80134e740dd411a)

    if [ $instance -eq "frontend" ]; then

ip=$(aws ec2 describe-instances \
    --instance-ids $instance \
    --query "Reservations[*].Instances[*].PublicIpAddress" \
    --output text)
    else
  ips=$(aws ec2 describe-instances \
    --instance-ids $instance \
    --query "Reservations[*].Instances[*].PrivateIpAddress" \
    --output text)  
    r53_record="$instance.$domain_name"
    echo "route53 record - $r53_record"
fi
done
