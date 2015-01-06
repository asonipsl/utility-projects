# !/bin/bash

# Check for proper number of command line args.
EXPECTED_ARGS=2
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {HOST_IP} {COMMAND_ID}"
  exit $E_BADARGS
fi

HOST=$1
COMMAND_ID=$2
URL=http://$HOST:7180/api/v4/commands/$COMMAND_ID

response=`sh rest_call.sh GET $URL`

#echo response=$response

sh parse_execution_response.sh "$response"

# STATUS CODES : { 0 - Successful Completion, 1 - Command in progress, 2 - Failure Completion, 3 - Error }
exit $?
