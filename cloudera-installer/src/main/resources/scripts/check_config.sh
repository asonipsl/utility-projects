# !/bin/bash

# Check for proper number of command line args.
EXPECTED_ARGS=1
E_BADARGS=65
RETRY_COUNT=5


if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {CONFIG_PROP_FILE}"
  exit $E_BADARGS
fi


CONFIG_PROP_FILE=$1
CONFIG_EXIST=2

# Check if file exists
if [ -f $CONFIG_PROP_FILE ]; then

	# Check if property exist
	. $CONFIG_PROP_FILE

	CONFIG_EXIST=0

	if [[ -n "$cluster_name" && -n "$host_count" && -n "$ntp_server_ip" ]]; then
		
		counter=1
		while [ $counter -le $host_count ]
		do
			varHostName="host_name_$counter"
			varHostIP="host_ip_$counter"
			if [[ "" = "${!varHostName}" ||  "" = "${!varHostIP}" ]]; then
				CONFIG_EXIST=1
				break
			fi
			((counter++))
		done
	else
		CONFIG_EXIST=1
	fi
fi

# If property file exist check whether to use existing configuration
if [ $CONFIG_EXIST -eq 1 ]; then
	
	echo "Error : Incorrrect property file format"
	exit $CONFIG_EXIST

elif [ $CONFIG_EXIST -eq 2 ]; then

	echo "Error : Property file doesn't exist : $CONFIG_PROP_FILE"
	exit $CONFIG_EXIST
	
fi