#!/bin/bash

# This script will poll the status of an Elastic Beanstalk environment and print it to the console.

environment_name="AssuredWS1-PlymouthRock-Production" # Replace with your Elastic Beanstalk environment name

while true; do
	status=$(aws elasticbeanstalk describe-environments --environment-names "$environment_name" --query "Environments[0].Status" --output text)

	echo "Environment status: $status"

	sleep 2 # Poll every 2 seconds
done
