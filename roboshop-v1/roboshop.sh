#!/bin/bash
ami_id="ami-0055977a6e828a4f4"
zone_id="Z06556651FH3Z7Y34VUG6"
domain_name="immaniyelu.shop"
apps=("catalogue" "user" "shipping" "payment" "cart" "dispatch")
web="frontend"
db=("mysql" "rabbitmq" "redis" "mongodb")
if [ "$#" -eq "0" ]; then
echo "Please pass one argument"
echo "USAGE :: $0 [web | db | apps ]"
exit 1
fi

if [ "$1" = "web" ]; then
web_instance_id=$(aws ec2 run-instances \
    --image-id $ami_id \
    --instance-type t3.micro \
   --security-group-ids sg-0e1875cf2c9414138 \
    --subnet-id subnet-09cc0b32fa38571c7 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-frontend}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

web_ip=$(aws ec2 describe-instances \
  --instance-ids "$web_instance_id" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)
web_r53=$(aws route53 change-resource-record-sets \
  --hosted-zone-id "$zone_id" \
  --change-batch '{
    "Comment": "Update frontend DNS record",
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'frontend.immaniyelu.shop'",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [
            {
              "Value": "'${web_ip}'"
            }
          ]
        }
      }
    ]
  }')

elif 
  [ "$1" = "db" ]; then 
for instance in "${db[@]}"
do
echo "Instace is db createing $instance"
db_instance_id=$(aws ec2 run-instances \
    --image-id $ami_id \
    --instance-type t3.micro \
   --security-group-ids sg-0e1875cf2c9414138 \
    --subnet-id subnet-09cc0b32fa38571c7 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-${instance}}]" \
    --query 'Instances[0].InstanceId' \
    --output text)
db_ip=$(aws ec2 describe-instances \
  --instance-ids "$db_instance_id" \
  --query 'Reservations[0].Instances[0].PrivateIpAddress' \
  --output text)

db_r53=$(aws route53 change-resource-record-sets \
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
              "Value": "'${db_ip}'"
            }
          ]
        }
      }
    ]
  }')
done
elif
[ "$1" = "apps" ]; then
for instance in "${apps[@]}"
do
echo "Instace is apps createing $instance"
app_instance_id=$(aws ec2 run-instances \
    --image-id $ami_id \
    --instance-type t3.micro \
   --security-group-ids sg-0e1875cf2c9414138 \
    --subnet-id subnet-09cc0b32fa38571c7 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-${instance}}]" \
    --query 'Instances[0].InstanceId' \
    --output text)
app_ip=$(aws ec2 describe-instances \
  --instance-ids "$app_instance_id" \
  --query 'Reservations[0].Instances[0].PrivateIpAddress' \
  --output text)
app_r53=$(aws route53 change-resource-record-sets \
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
              "Value": "'${app_ip}'"
            }
          ]
        }
      }
    ]
  }')
  done
  else 

  echo "Please pass atleast one argument"
  exit 0

  fi