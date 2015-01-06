# !/bin/bash

# Check for proper number of command line args.
EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {CONFIG_PROP_FILE}"
  exit $E_BADARGS
fi

CONFIG_PROP_FILE=$1
HOST_COUNT_PROP="host_count"

#remove existing property file
rm -f $CONFIG_PROP_FILE

echo -e "# Cloudera Cluster Installation Configuration Properties\n" > $CONFIG_PROP_FILE

# Capture cluster name
sh capture_str_input.sh "Cluster name" "cluster_name" $CONFIG_PROP_FILE
status=$?

if [ $status -ne 0 ]; then
	echo "Error : Unable to capture Cluster name : $status"
        exit $status
fi


# Capture number of nodes in the cluster
sh capture_num_input.sh "number of nodes in Cloudera cluster" $HOST_COUNT_PROP $CONFIG_PROP_FILE
status=$?

if [ $status -ne 0 ]; then
	echo "Error : Unable to capture number of nodes : $status"
	exit $status
fi

. ./$CONFIG_PROP_FILE

max_count=${!HOST_COUNT_PROP}
counter=1

while [[ $status -eq 0  && $counter -le $max_count ]]
do
	# Capture host name
	sh capture_str_input.sh "host-$counter name" "host_name_$counter" $CONFIG_PROP_FILE
	status=$?

	if [ $status -ne 0 ]; then
        	echo "Error : Unable to capture host-$counter name : $status"
	        exit $status
	fi

	# Capture host ip
	sh capture_ip_input.sh "host-$counter" "host_ip_$counter" $CONFIG_PROP_FILE
        status=$?

        if [ $status -ne 0 ]; then
                echo "Error : Unable to capture host-$counter IP : $status"
                exit $status
        fi
	((counter++))
done

# Capture NTP Server IP
sh capture_ntp_server_input.sh "ntp_server_ip" $CONFIG_PROP_FILE
status=$?

if [ $status -ne 0 ]; then
        echo "Error : Unable to capture NTP Server IP : $status"
        exit $status
fi


echo Capturing Config Inputs ... [ "##################################################" ] 100%
exit $status
