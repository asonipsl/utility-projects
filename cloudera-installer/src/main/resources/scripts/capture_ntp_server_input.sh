# !/bin/bash


# Check for proper number of command line args.
EXPECTED_ARGS=2
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {INPUT_PROP} {PROP_FILE}"
  exit $E_BADARGS
fi

RETRY_COUNT=5
INPUT_PROP=$1
PROP_FILE=$2
status=1
counter=0

while [[ $status -eq 1  && $counter -lt $RETRY_COUNT ]]
do
	# Read number of hosts in cluster
	if [ $counter -eq 0 ]; then
		read -e -p "Enter NTP Server IP : " IP_INPUT
	else
		read -e -p "Incorrect Entry. Enter valid NTP Server IP : " IP_INPUT
	fi

	# Check ntpd service and stop if already started
	#service ntpd status
	#ntpd_status=$?
	#if [ $ntpd_status -eq 0 ]; then
	#	service ntpd stop
	#fi

	# validate ip address
	ntpdate $IP_INPUT
	validation_check=$?

	# start ntpd service if it was already running
	#if [ $ntpd_status -eq 0 ]; then
	#	service ntpd start
	#fi

	if  [[ $validation_check -eq 0 ]] ; then
                status=0
                echo Input \"$IP_INPUT\" Recorded ...
                echo $INPUT_PROP=$IP_INPUT >> $PROP_FILE
        fi

	(( counter++ ))
done

if [ $counter -eq $RETRY_COUNT ] && [ $status -eq 1 ]; then
	echo Maximum allowed attempts for entering  NTP Server IP  exceeded. Aborting...
fi

exit $status
