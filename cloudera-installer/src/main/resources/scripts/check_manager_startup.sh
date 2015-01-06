# !/bin/bash

# Check for proper number of command line args.
EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {HOST_IP}"
  exit $E_BADARGS
fi

HOST=$1
counter=0

echo -n Checking Manager Startup ... [ "#####" ] 10%

while [[ $counter -lt 40 ]]
do
	curl --silent http://$HOST:7180 > /dev/null
	if [ $? -ne 0 ]; then
	        sleep 5
                (( counter++ ))
		echo -ne \\b\\b\\b\\b\\b\\b"#" ] $((counter*2+10))%
	else
		echo -ne \\r
	        echo  Checking Manager Startup ... [ "##################################################" ] 100%
		exit 0
        fi
done

# If code reaches here, then server hasn't started yet
echo ' '
exit 1 
