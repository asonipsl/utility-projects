#!/bin/bash

# Check for proper number of command line args.
MINIMUM_ARGS=3
E_BADARGS=65

if [ $# -lt $MINIMUM_ARGS ]
then
  echo "Usage: `basename $0` {HTTP_METHOD} {HOST_IP} {API_URL} [DATA]"
  exit $E_BADARGS
fi

HTTP_METHOD=$1
HOST=$2
API_URL=$3
DATA=$4

URL=http://$HOST:7180/api/v4/$API_URL

#echo URL=$URL

if [ -n "$DATA" ]; then
        response=`sh rest_call.sh $HTTP_METHOD $URL $DATA`
else
        response=`sh rest_call.sh $HTTP_METHOD $URL`
fi

#echo response=$response

status=1
counter=0

# Check response returned
if [ -n "$response" ]; then
	sh parse_execution_response.sh "$response"
	status=$?
else
	# Error occurred
	status=4
fi

# STATUS CODES : { 0 - Successful Completion, 1 - Command in progress, 2 - Failure Completion, 3 - Error }
exit $status
