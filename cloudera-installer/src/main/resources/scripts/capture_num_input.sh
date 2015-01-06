# !/bin/bash


# Check for proper number of command line args.
EXPECTED_ARGS=3
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {INPUT_STR} {INPUT_PROP} {PROP_FILE}"
  exit $E_BADARGS
fi

RETRY_COUNT=5
RE='^[0-9]+$'
INPUT_STR=$1
INPUT_PROP=$2
PROP_FILE=$3
status=1
counter=0

while [[ $status -eq 1  && $counter -lt $RETRY_COUNT ]]
do
	# Read number of hosts in cluster
	if [ $counter -eq 0 ]; then
		read -e -p "Enter $INPUT_STR : " NUM_INPUT
	else
		read -e -p "Incorrect Entry. Enter valid $INPUT_STR : " NUM_INPUT
	fi

	# validate number
	if  [[ $NUM_INPUT =~ $RE ]] ; then
		status=0
		echo Input \"$NUM_INPUT\" Recorded ...
		echo $INPUT_PROP=$NUM_INPUT >> $PROP_FILE
	fi

	(( counter++ ))
done

if [ $counter -eq $RETRY_COUNT ] && [ $status -eq 1 ]; then
	echo Maximum allowed attempts for entering \"$INPUT_STR\" exceeded. Aborting...
fi

exit $status
