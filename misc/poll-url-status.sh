#!/bin/bash

# This script will send a request to the specified URL and display the status code and response body on a single line.
# It will then wait for 2 seconds before making the next request.

url="http://plymouthrock-ws1-prod.assuredclaims.net/health" # Replace with your desired URL

while true; do
	response=$(curl -s -w "%{http_code}" "$url") # Send the curl request and store the response

	# Extract the status code and response body from the combined output
	status_code=${response: -3}                # Extract last 3 characters as the status code
	response_body=${response:0:${#response}-3} # Extract the remaining characters as the response body

	# Display the status code and response body on a single line
	echo "Status code: $status_code - Response body: $response_body"

	sleep 2 # Wait for 2 seconds before making the next request
done
