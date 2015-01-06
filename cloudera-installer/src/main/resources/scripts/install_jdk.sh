#!/bin/bash

# Check if jdk is installed or not
javac -version
status=$?
if [ $status -ne 2 ]; then 

	# Download the jdk rpm required by cloudera
	#wget http://archive.cloudera.com/cm4/redhat/6/x86_64/cm/4/RPMS/x86_64/jdk-6u31-linux-amd64.rpm
	#status=$?
        #if [ $status -ne 0 ]; then
        #        echo "Error: Unable to download jdk... : $status"
        #        exit $status
        #fi
	
	# Install the jdk
	yum -y install jdk
	status=$?
	if [ $status -eq 0 ]; then
		sed -i '/JAVA_HOME=/d' /etc/profile
		echo "export JAVA_HOME=/usr/java/default" >> /etc/profile
		status=$?
		if [ $status -ne 0 ]; then
			echo "Error: Unable to set JAVA_HOME... : $status"
			exit $status
		fi
		rm -f jdk-6u31-linux-amd64.rpm
		exit 0
	else
		echo "Error: jdk installation failed... : $status"
		exit $status
	fi
else
	if [ "$JAVA_HOME" = "" ]; then
		sed -i '/JAVA_HOME=/d' /etc/profile
		echo "export JAVA_HOME=/usr/java/default" >> /etc/profile
                status=$?
                if [ $status -ne 0 ]; then
                        echo "Error: Unable to set JAVA_HOME... : $status"
                        exit $status
                fi
                exit 0
	fi
fi
