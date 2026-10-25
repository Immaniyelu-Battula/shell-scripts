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
    --security-group-ids sg-0e1875cf2c9414138 \
    --subnet-id subnet-09cc0b32fa38571c7)

ip=$(aws ec2 describe-instances \
    --instance-ids $instance_id \
    --query "Reservations[*].Instances[*].PublicIpAddress" \
    --output text)

r53=$(aws route53 change-resource-record-sets \
  --hosted-zone-id $zone_id \
  --change-batch '{
    "Comment": "Update frontend DNS record",
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "$instance.immaniyelu.shop",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [
            {
              "Value": "$ip"
            }
          ]
        }
      }
    ]
  }')
   
done




