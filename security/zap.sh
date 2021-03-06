#!/bin/sh

DOCKER=`which docker`
IMAGE='owasp/zap2docker-weekly'
URL='https://www.example.com'
ZAP_API_PORT='8090'

# Start our container
CONTAINER_ID=`$DOCKER run -d \
  -p $ZAP_API_PORT:$ZAP_API_PORT \
  -v $PWD:/zap/reports:rw \
  -i $IMAGE zap.sh \
  -daemon -port $ZAP_API_PORT \
  -host 0.0.0.0 \
  -config api.disablekey=true`

# set up our status spinner
spin='-\|/'
i=0;

# Poll the api and wait for it to start up
# while ! curl -s http://0.0.0.0:$ZAP_API_PORT > /dev/null
# do
#  i=$(( (i+1) %4 ))
#  printf "\rWaiting for OWASP ZAP to start ${spin:$i:1}"
#  sleep .1
# done
# The polling isn't currently working, so just sleep
sleep 30

echo "\nZAP has successfully started"

# Open the provided url
$DOCKER exec $CONTAINER_ID \
  zap-cli -p $ZAP_API_PORT open-url $URL

# Spider the site
$DOCKER exec $CONTAINER_ID \
  zap-cli -v -p $ZAP_API_PORT spider $URL

# Scan the site
$DOCKER exec $CONTAINER_ID \
  zap-cli -v -p $ZAP_API_PORT active-scan \
  --recursive $URL

# Show any alerts
$DOCKER exec $CONTAINER_ID \
  zap-cli -p $ZAP_API_PORT alerts -l Low

# Generate our report
$DOCKER exec $CONTAINER_ID \
  zap-cli -p $ZAP_API_PORT report \
  -o /zap/reports/report.html -f html

# Shut down the docker image
$DOCKER kill $CONTAINER_ID
