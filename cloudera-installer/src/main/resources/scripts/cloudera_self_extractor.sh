#!/bin/sh -e
echo "Starting the installer..."
sed -e '1,/^exit$/d' "$0" | tar xzf -
CONFIG_PROP_FILE=/var/lib/gc-ml/cloudera.conf
CONFIG_EXIST=2
RE='^[0-9]+$'

# Check if file exists
if [ -f $CONFIG_PROP_FILE ]; then

	# Check if property exist
	. $CONFIG_PROP_FILE

	CONFIG_EXIST=0

	if [ "" = "$cluster_name" ] || [ "" = "$host_count" ] \
	|| [ "" = "$ntp_server_ip" ] || ! [[ $host_count =~ $RE ]] \
	|| [ $host_count -lt 3 ]; then
	  echo "Error : Missing or Incorrect configuration properties"
	  CONFIG_EXIST=1
	else
	  # validate ntp server
	  ping -c 1 $ntp_server_ip
	  status=$?
	  if [ $status -ne 0 ] ; then
		echo "Error : NTP Server not reachable : $ntp_server_ip : $status"
		CONFIG_EXIST=1
		break
	  fi
	  counter=1
	  while [ $counter -le $host_count ]
	  do
		varHostName="host_name_$counter"
		varHostIP="host_ip_$counter"
		if [[ "" = "${!varHostName}" || "" = "${!varHostIP}" ]]; then
		  echo "Error : Missing configuration property : $varHostName $varHostIP"
		  CONFIG_EXIST=1
		  break
		else
                  echo "Checking reachability of host [ ${!varHostName} ]"
		  ping -c 1 ${!varHostIP}
		  status=$?
		  if [ $status -ne 0 ] ; then
			echo "Error : IP not reachable : ${!varHostIP} : $status"
			CONFIG_EXIST=1
			break
                  else
                      echo "Host [ ${!varHostName} ] reachable status...       [ OK ]"
		  fi
		fi
		((counter++))
	  done
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

#Execute the installer
_script="$(readlink -f ${BASH_SOURCE[0]})"
BASE_DIR="$(dirname $_script)"

sh $BASE_DIR/scripts/cloudera_install.sh $CONFIG_PROP_FILE
exit
