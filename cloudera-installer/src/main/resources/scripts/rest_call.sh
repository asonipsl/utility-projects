#!/bin/bash

# Check for proper number of command line args.
MINIMUM_ARGS=2
E_BADARGS=65

if [ $# -lt $MINIMUM_ARGS ]
then
  echo "Usage: `basename $0` {HTTP_METHOD} {URL} [DATA]"
  exit $E_BADARGS
fi

METHOD=$1
URL=$2
DATA=$3

#echo URL=$URL
#echo METHOD=$METHOD
#echo DATA=$DATA

# Create CURL ARGS 
if [ -n "$DATA" ]; then
	response=`curl -ss -H "Content-Type:Application/json" -X $METHOD -u admin:admin $URL -d $DATA`
else
	response=`curl -ss -H "Content-Type:Application/json" -X $METHOD -u admin:admin $URL`
fi

#response=`curl $CURL_ARGS`

echo $response
