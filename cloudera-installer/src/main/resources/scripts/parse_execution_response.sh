#!/bin/bash

# Check for proper number of command line args.
EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {JSON_DATA}"
  exit $E_BADARGS
fi

DATA=$1

#echo DATA=$DATA

# STATUS CODES : { 0 - Successful Completion, 1 - Command in progress, 2 - Failure Completion, 3 - Error }
STATUS_CODE=1

# Check if command has completed. If completed active is false
ACTIVE_FLAG=`python parse_json.py "$DATA" "active"`
#echo ACTIVE=----------$ACTIVE_FLAG----------------

if [ "$ACTIVE_FLAG" = "False" ]; then
	#echo Inside Loop
        # Check if command has successfully completed. If yes success is true
        SUCCESS_FLAG=`python parse_json.py "$DATA" "success"`
        #echo SUCCESS=$SUCCESS_FLAG
        if [ "$SUCCESS_FLAG" = "False" ]; then
                STATUS_CODE=2
        else
                STATUS_CODE=0
        fi
fi

exit $STATUS_CODE
