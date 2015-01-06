#!/bin/bash

# Check for proper number of command line args.
EXPECTED_ARGS=3
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {HOST} {CLUSTER_NAME} {DATA}"
  exit $E_BADARGS
fi

HOST=$1
CLUSTER_NAME=$2
DATA=$3

echo -n Importing Deployment Descriptor  ... [ "#####" ] 10%

DEPLOYMENT_URL=http://$HOST:7180/api/v4/cm/deployment
CLUSTER_CHECK_URL=http://$HOST:7180/api/v4/clusters/$CLUSTER_NAME

#echo URL=$URL

response=`sh rest_call.sh PUT $DEPLOYMENT_URL $DATA`

#echo response=$response

status=1

# Check response returned
if [ -n "$response" ]; then

	response=`sh rest_call.sh GET $CLUSTER_CHECK_URL`

	# Check response returned
	if [ -n "$response" ]; then

		cluster_name=`python parse_json.py "$response" "name"`

		if [ "$CLUSTER_NAME" = "$cluster_name" ]; then

			echo -ne \\r
			echo Importing Deployment Descriptor ... [ "##################################################" ] 100%
			exit 0
		fi

	else
	        # Error occurred
        	status=2
	fi

fi

# STATUS CODES : { 0 - Successful Completion, 1 - No Response, 2 - Deployment Failed }
exit $status
