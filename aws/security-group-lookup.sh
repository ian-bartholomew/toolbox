#!/bin/bash

# Script to find what network interfaces are using a security group

GROUP_ID=sg-xxx
REGION=region name

aws ec2 describe-network-interfaces \
  --filters Name=group-id,Values=$GROUP_ID \
  --region $REGION \
  --output json \
  --query 'NetworkInterfaces[*]'.['NetworkInterfaceId','Description','PrivateIpAddress','VpcId'] | jq
