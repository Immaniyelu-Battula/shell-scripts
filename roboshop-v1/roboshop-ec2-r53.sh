#!/bin/bash
ami_id="ami-0055977a6e828a4f4"
zone_id="Z06556651FH3Z7Y34VUG6"
domain_name="immaniyelu.shop"


for instance in $@
do
echo "Instace is createing $instance"
instance_id=$(aws ec2 run-instances \
    --image-id $ami_id \
    --instance-type t3.micro \
   --security-group-ids sg-0e1875cf2c9414138 \
    --subnet-id subnet-09cc0b32fa38571c7 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]' \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "insatnce id is : $instance_id "

ip=$(aws ec2 describe-instances \
  --instance-ids "$instance_id" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

r53=$(aws route53 change-resource-record-sets \
  --hosted-zone-id "$zone_id" \
  --change-batch '{
    "Comment": "Update frontend DNS record",
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'${instance}.immaniyelu.shop'",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [
            {
              "Value": "'${ip}'"
            }
          ]
        }
      }
    ]
  }')

echo "Record added in route53 : $r53"   
done




