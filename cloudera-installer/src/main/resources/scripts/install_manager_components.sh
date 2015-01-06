#!/sbin/bash
# this script will run on individual hosts and setup required environment for installation

EXPECTED_ARGS=2
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ];
then
  echo "Usage: `basename $0` {MASTER_HOSTNAME} {CURRENT_HOSTNAME}"
  exit $E_BADARGS
fi

MASTER_HOSTNAME=$1
CURRENT_HOSTNAME=$2
SED_CMD_AGENT_CONFIG=s/server_host=localhost/server_host=$MASTER_HOSTNAME/g

# Creating environment variable entry in profile for zookeeper
status=`cat /etc/profile | grep "ZOO_DATADIR_AUTOCREATE_DISABLE"`
if [ $? -ne 0 ]; then
	echo export ZOO_DATADIR_AUTOCREATE_DISABLE=false >> /etc/profile
fi

# Creating environment variable entry in profile for zookeeper hostname
status=`cat /etc/profile | grep "ZOOKEEPER_HOSTNAME"`
if [ $? -ne 0 ]; then
        echo export ZOOKEEPER_HOSTNAME=$MASTER_HOSTNAME >> /etc/profile
fi

status=`cat /etc/profile | grep "NAMENODE_FQDN"`
if [ $? -ne 0 ]; then
        echo export NAMENODE_FQDN=$MASTER_HOSTNAME >> /etc/profile
fi

status=`cat /etc/profile | grep "NAMENODE_PORT"`
if [ $? -ne 0 ]; then
        echo export NAMENODE_PORT=8020 >> /etc/profile
fi

status=`cat /etc/profile | grep "JOBTRACKER_FQDN"`
if [ $? -ne 0 ]; then
        echo export JOBTRACKER_FQDN=$MASTER_HOSTNAME >> /etc/profile
fi

status=`cat /etc/profile | grep "JOBTRACKER_PORT"`
if [ $? -ne 0 ]; then
        echo export JOBTRACKER_PORT=8021 >> /etc/profile
fi

status=`cat /etc/profile | grep "OOZIE_FQDN"`
if [ $? -ne 0 ]; then
        echo export OOZIE_FQDN=$MASTER_HOSTNAME >> /etc/profile
fi

status=`cat /etc/profile | grep "OOZIE_PORT"`
if [ $? -ne 0 ]; then
        echo export OOZIE_PORT=11000 >> /etc/profile
        source /etc/profile
fi


# Previous data clean up
yum -y erase cloudera-manager-daemons cloudera-manager-server cloudera-manager-server-db cloudera-manager-agent expect
rm -rf /var/lib/cloudera-scm-server-db
rm -rf /opt/dfs
rm -rf /etc/cloudera-scm-server


if [ "$CURRENT_HOSTNAME" == "$MASTER_HOSTNAME" ];then

	# Installing Cloudera Server and Agent RPMs in master node
	yum -y install cloudera-manager-daemons cloudera-manager-server cloudera-manager-server-db cloudera-manager-agent expect
	status=$?
	if [ $status -ne 0 ];then
	        echo "Error: Unable to isntall Cloudera RPMs in Master Node : $status"
	        exit $status
	fi

	# Starting Cloudera Server DB
	/etc/init.d/cloudera-scm-server-db start
	status=$?
        if [ $status -ne 0 ];then
                echo "Error: Unable to start Cloudera Server DB : $status"
                exit $status
        fi

	# Check if log4j.properties file exists
	if [ -f /etc/cloudera-scm-server/log4j.properties  ]; then
		echo "Log file check status : true"
	else
		echo "Error: Unable to find log4j.properties file for Cloudera Server : $status"
                exit $status
	fi

	# Starting Cloudera Server
	/etc/init.d/cloudera-scm-server start
	status=$?
        if [ $status -ne 0 ];then
                echo "Error: Unable to start Cloudera Server : $status"
                exit $status
        fi

else
	# Installing Cloudera Agent RPMs in other nodes
	yum -y install cloudera-manager-daemons cloudera-manager-agent
	status=$?
        if [ $status -ne 0 ];then
                echo "Error: Unable to isntall cloudera Agent RPMs : $status"
                exit $status
        fi

fi

# Configuring Cloudera Agent
sed -i "$SED_CMD_AGENT_CONFIG" /etc/cloudera-scm-agent/config.ini
status=$?
if [ $status -ne 0 ];then
        echo "Error: Unable to configure Cloudera Agent : $status"
        exit $status
fi

# Starting Cloudera Agent
/etc/init.d/cloudera-scm-agent start
status=$?
if [ $status -ne 0 ];then
        echo "Error: Unable to start Cloudera Agent : $status"
        exit $status
fi

# Return Success code
exit 0
