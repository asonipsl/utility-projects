# !/bin/bash

# Check for proper number of command line args.
MINIMUM_ARGS=3
E_BADARGS=65

if [ $# -lt $MINIMUM_ARGS ]
then
  echo "Usage: `basename $0` {DISPLAY_MSG} {HTTP_METHOD} {HOST_IP} {API_URL} [DATA]"
  exit $E_BADARGS
fi

DISPLAY_MSG=$1
HTTP_METHOD=$2
HOST=$3
API_URL=$4
DATA=$5

#echo DATA=$DATA

URL=http://$HOST:7180/api/v4/$API_URL

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

	# Retrieve command id
	command_id=`python parse_json.py "$response" "id"`

	#echo command_id=$command_id

	if [ "$command_id" = "" ]; then
		echo "Error : No Command Id found"
		status=4
	fi

	#echo command_id_2=$command_id
	echo -n $DISPLAY_MSG ... [ "#####" ] 10%

	while [[ $status -eq 1  && $counter -lt 40 ]]
	do
        	# Check command completion based on command id
		sh execute_sync_command.sh GET $HOST commands/$command_id
		status=$?
		#echo status=$status
		if [ -n "$status" ]; then
			if [ $status -eq 1 ]; then
	        	        sleep 15
				#echo counter=$counter
				(( counter++ ))
				echo -ne \\b\\b\\b\\b\\b\\b"#" ] $((counter*2+10))%
		        fi
		else
		        # Error occurred
		        status=4
		fi
	done
	if [ $status -eq 0 ]; then
		echo -ne \\r
		echo  $DISPLAY_MSG ... [ "##################################################" ] 100%
	else
		echo ' '
	fi
else
        # Error occurred
        status=4
fi

# STATUS CODES : { 0 - Successful Completion, 1 - Command in progress, 2 - Failure Completion, 3 - Error }
exit $status
