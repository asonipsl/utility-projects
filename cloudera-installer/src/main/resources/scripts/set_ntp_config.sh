#!/sbin/bash
# this script will run on individual hosts and setup required environment for installation

# Check for proper number of command line args.
EXPECTED_ARGS=1
E_BADARGS=65

echo "NTP SERVER IP : $1"
if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {NTP_SYNC_IP}"
  exit $E_BADARGS
fi

# Setting up environment variables
TIME_SYNC_IP=$1
SED_CMD_NTP="/server 0/ i\server $TIME_SYNC_IP"


yum -y install ntp*
status=$?
if [ $status -ne 0 ];then
        echo "Error: Unable to install ntp service : $status"
        exit $status
fi

# Stopping ntpd service
service ntpd stop

# Configuring ntp server setting
#echo SED_CMD_NTP=$SED_CMD_NTP
status=`cat /etc/ntp.conf | grep "server $TIME_SYNC_IP"`
if [ $? -ne 0 ]; then

	sed -i "$SED_CMD_NTP" /etc/ntp.conf
	status=$?
	if [ $status -ne 0 ];then
	        echo "Error: Unable to configure ntp server setting : $status"
	        exit $status
	fi

fi

# Synchronizing time with ntp server
ntpdate $TIME_SYNC_IP
status=$?
if [ $status -ne 0 ];then
        echo "Error: Unable to sync time with ntp server : $status"
        exit $status
fi

# Starting ntpd service
service ntpd start
status=$?
if [ $status -ne 0 ];then
        echo "Error: Unable to start ntp server : $status"
        exit $status
fi

# Return Success code
exit 0
