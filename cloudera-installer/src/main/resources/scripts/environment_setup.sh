#!/sbin/bash
# This script does the basic setup on master node (i.e. first node in the list)

EXPECTED_ARGS=2
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {config_property_file_path} {REST_PROP_FILE}"
  exit $E_BADARGS
fi

REST_PROP_FILE=$2

# Source property file
source $1
status=$?
if [ $status -ne 0 ]; then
	echo "Error: Unable to sorce the property file : $1 : $status"
	exit $status
fi


# Create REST Service Configuration
echo "# Rest Service Config properties" > $REST_PROP_FILE
echo "" >> $REST_PROP_FILE
echo "node_count=2" >> $REST_PROP_FILE
echo "node_name_1=$host_name_2" >> $REST_PROP_FILE
echo "node_name_2=$host_name_3" >> $REST_PROP_FILE
echo "" >> $REST_PROP_FILE
echo "# Cloudera Master Node" >> $REST_PROP_FILE
echo "" >> $REST_PROP_FILE
echo "cloudera_hostname=$host_name_1" >> $REST_PROP_FILE


# Go to the directory containg current script
_script="$(readlink -f ${BASH_SOURCE[0]})"
SCRIPTS_BASE_DIR="$(dirname $_script)"
cd $SCRIPTS_BASE_DIR
status=$?
if [ $status -ne 0 ]; then
        echo "Error: Unable to go to installation scripts directory : $status"
        exit $status
fi

# Check if ssh isntalled
ssh
status=$?
if [ $status -ne 255 ]; then
	echo "Error: SSH not installed. Please install SSH and set password less ssh"
	echo "from Master Node (i.e. Current Machine) to other nodes..."
	echo "Aborting setup..."
        exit $status
fi

# Check if ssh public key are present
if [ ! -f /root/.ssh/id_rsa.pub ]; then	
	echo "SSH Public key not found. Password less ssh required for installation."
	echo "Please set password less ssh from current node to other nodes."
        echo "Aborting setup..."
	exit 1
fi


# Enter IP, HOSTNAME and FQDN entry in temporary hosts files
rm -f *.tmp
echo "$host_ip_1 $host_name_1 " > hostFile.tmp
status=$?
if [ $status -ne 0 ]; then
        echo "Error: Unable to copy ip and host information: $status"
        exit $status
fi

c=2
while [ $c -le $host_count ]
do
	varHostIP="host_ip_$c"
	echo "$varHostIP"
	# This command will attempt to execute sample command by ssh without password
	# to check if password less ssh is set up or not.
	echo "Pass 1: ${!varHostIP}"

	ssh -o 'PreferredAuthentications=publickey' root@${!varHostIP} "echo"
	if [ $? -eq 255 ]; then

		echo "Pass 2: ${!varHostIP}"
		echo "Copying SSH Public Key to : ${!varHostIP}"
		ssh-copy-id -i ~/.ssh/id_rsa.pub root@${!varHostIP}
		status=$?
		if [ $status -ne 0 ];then
			echo "Password less ssh not found for ${!varHostIP}... Aborting setup."
			exit $status 
		fi

	else
		varHostName="host_name_$c"
	        varHostIP="host_ip_$c"
	        REMOTE_IP="${!varHostIP}"
	       	REMOTE_HOSTNAME="${!varHostName}"
		# Make entry for current node in temporary hosts file
		echo "$REMOTE_IP $REMOTE_HOSTNAME" >> hostFile.tmp
		status=$?
		if [ $status -ne 0 ]; then
			echo "Error: Unable to copy ip and host information: $status"
			exit $status
		fi
		
	fi

	# Increment counter
	(( c++ ))
	status=$?
       	if [ $status -ne 0 ]; then
        	echo "Error: Unable to increment counter: $status"
                exit $status
      	fi
done

# Update Hosts file
while IFS= read -r line
do
        HOST_IP=`echo "$line" | awk '{print $1}'`
        HOST_NAME=`echo "$line" | awk '{print $2}'`
	sh update_hosts_file.sh $HOST_IP $HOST_NAME
	status=$?
	if [ $status -ne 0 ]; then
	        echo "Error: Unable to configure /etc/hosts file on node : $host_ip_1 :: status : $status"
	        exit $status
	fi
done < "hostFile.tmp"

# Execute the setup files and remove files after the job is finished

echo "#############################################################"
echo "################ Installing on Master Node ##################"
echo "#############################################################"

echo "Disabling firewall and disabling SELinux"
sh set_iptables_selinux.sh
status=$?
if [ $status -ne 0 ]; then
        echo "Error: Unable to stop iptables and|or SELinux: $status"
        exit $status
fi


echo "Setting yum repo"
sh set_yum_repo.sh
status=$?
if [ $status -ne 0 ]; then
        echo "Error: Unable to set yum repo for Cloudera RPMs: $status"
        exit $status
fi

echo "Installing JDK 1.6..."
sh install_jdk.sh
status=$?
if [ $status -ne 0 ]; then
        echo "Error: Unable to install JDK 1.6 : $status"
        echo "Install JDK Manually and start installation again"
        exit $status
fi

echo "Installing Cloudera RPMs"
sh install_manager_components.sh $host_name_1 $host_name_1
status=$?
if [ $status -ne 0 ]; then
        echo "Error: Unable to install Cloudera RPMs: $status"
        exit $status
fi

#echo "executing loop"
# Execute setup script on remote nodes
c=2
while [ $c -le $host_count ]
do	
	#echo "in loop : $SETUP_DIR"	
	varHostIP="host_ip_$c"
        REMOTE_IP="${!varHostIP}"
	varHostName="host_name_$c"
        REMOTE_NAME="${!varHostName}"

	# Execute the setup creation script on remote nodes
	echo "#############################################################"
	echo "################ Installing on Remote Node ##################"
	echo "#############################################################"
	echo "Node Name: $REMOTE_NAME"
	while IFS= read -r line
	do
	        HOST_IP=`echo "$line" | awk '{print $1}'`
	        HOST_NAME=`echo "$line" | awk '{print $2}'`
	        ssh $REMOTE_IP "bash -s" -- < update_hosts_file.sh "$HOST_IP" "$HOST_NAME"
		status=$?
	        if [ $status -ne 0 ]; then
			echo "Error: Unable to configure /etc/hosts file on node : $host_ip_1 :: status : $status"
	                exit $status
	        fi
	done < "hostFile.tmp"


	# Execute the setup creation script on remote nodes
	echo " Stopping iptables and disabling selinux."
	ssh $REMOTE_IP "bash -s" -- < set_iptables_selinux.sh
	status=$?
	if [ $status -ne 0 ]; then
	        echo "Error: Unable to stop iptables and|or disable selinux: $status"
	        exit $status
	fi
	
	echo "Setting ntp server"
	ssh $REMOTE_IP "bash -s" -- < set_ntp_config.sh "$ntp_server_ip"
	status=$?
	if [ $status -ne 0 ]; then
	        echo "Error: Unable to set ntp server: $status"
	        exit $status
	fi

	echo "Setting yum repo "
	ssh $REMOTE_IP "bash -s" -- < set_yum_repo.sh
	status=$?
	if [ $status -ne 0 ]; then
	        echo "Error: Unable to set yum repo for Cloudera RPMs: $status"
	        exit $status
	fi

        ssh $REMOTE_IP "bash -s" -- < install_jdk.sh
        status=$?
        if [ $status -ne 0 ]; then
                echo "Error: Unable to install JDK 1.6 : $status"
                exit $status
        fi
	
	echo "Installing Cloudera RPMs "
	ssh $REMOTE_IP "bash -s" -- < install_manager_components.sh "$host_name_1" "$REMOTE_NAME"
	status=$?
	if [ $status -ne 0 ]; then
	        echo "Error: Unable to install Cloudera RPMs: $status"
	        exit $status
	fi

	# Increment counter
	(( c++ ))
	status=$?
        if [ $status -ne 0 ]; then
                echo "Error: Unable to increment counter: $status"
                exit $status
        fi

done
