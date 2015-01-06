#!/sbin/bash
# this script will run on individual hosts and setup required environment for installation

# Importing Cloudera key
wget http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera
status=$?
if [ $status -ne 0 ];then
        echo "Error: Unable to download Cloudera key : $status"
        exit $status
fi

mv "RPM-GPG-KEY-cloudera" /etc/yum.repos.d/
status=$?
if [ $status -ne 0 ];then
        echo "Error: Unable to move Cloudera key to yum repo: $status"
        exit $status
fi

rpm "--import" "/etc/yum.repos.d/RPM-GPG-KEY-cloudera"
status=$?
if [ $status -ne 0 ];then
        echo "Error: Unable to import Cloudera key : $status"
        exit $status
fi

sleep 5

status=$?
if [ $status -ne 0 ];then
        echo "Error: Unable to remove temporary Cloudera key : $status"
        exit $status
fi

# Download Cloudera CDH repo file
wget http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/cloudera-cdh4.repo
status=$?
if [ $status -ne 0 ];then
        echo "Error: Unable to download Cloudera CDH repo file : $status"
        exit $status
fi

sleep 5

# Download Cloudera Manager repo file
wget http://archive.cloudera.com/cm4/redhat/6/x86_64/cm/cloudera-manager.repo
status=$?
if [ $status -ne 0 ];then
        echo "Error: Unable to download Cloudera Manager repo file : $status"
        exit $status
fi

sleep 5

# Entering in to repo directory
mv cloudera-cdh4.repo /etc/yum.repos.d/
status=$?
if [ $status -ne 0 ];then
        echo "Error: Unable to move repo files to yum repository : $status"
        exit $status
fi

mv cloudera-manager.repo /etc/yum.repos.d/
status=$?
if [ $status -ne 0 ];then
        echo "Error: Unable to move repo files to yum repository : $status"
        exit $status
fi


# Clean yum repo
yum clean all
status=$?
if [ $status -ne 0 ];then
        echo "Error: Unable to clean yum repo : $status"
        exit $status
fi

# Return Success code
exit 0
