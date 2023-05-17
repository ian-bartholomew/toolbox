#!/bin/bash

# Check if the security group ID is provided as an argument
if [[ $# -eq 0 ]]; then
	echo "Please provide the security group ID as an argument."
	exit 1
fi

# Fetching the security group ID from the command-line argument
security_group_id=$1

# Fetching the AWS resources using the AWS CLI
resources=$(aws ec2 describe-instances --filters Name=instance.group-id,Values=$security_group_id \
	--query 'Reservations[*].Instances[*].[InstanceId, Tags[?Key==`Name`].Value | [0], State.Name]' \
	--output text)

# ANSI escape sequences for colors
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Printing the resources
echo -e "AWS Resources in Security Group: ${YELLOW}$security_group_id${NC}\n"
echo "-------------------------------------------------------------------------------------"

if [[ -z $resources ]]; then
	echo -e "${RED}No resources found in the security group.${NC}"
else
	printf "%-20s %-45s %s\n" "Instance ID" "Instance Name" "State"
	echo "-------------------------------------------------------------------------------------"
	# Sort the resources by name
	sorted_resources=$(echo "$resources" | sort -k2)

	while IFS=$'\t' read -r instance_id name state; do
		if [[ $state == "running" ]]; then
			printf "${YELLOW}%-20s${NC} %-45s ${GREEN}%s${NC}\n" "$instance_id" "$name" "$state"
		else
			printf "${YELLOW}%-20s${NC} %-45s ${RED}%s${NC}\n" "$instance_id" "$name" "$state"
		fi
	done <<<"$sorted_resources"
fi
