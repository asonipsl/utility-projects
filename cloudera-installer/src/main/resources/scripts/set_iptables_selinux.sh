#!/sbin/bash
# this script will run on individual hosts and setup required environment for installation

# Disabling firewall
service iptables stop
status=$?
if [ $status -ne 0 ];then
	echo "Error: Unable to disable iptables : $status"
	exit $status
fi

# Disabling SELinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
status=$?
if [ $status -ne 0 ];then
        echo "Error: Unable to disable SELinux : $status"
        exit $status
fi

exit 0
