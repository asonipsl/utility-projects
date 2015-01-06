#!/bin/bash
# Create supergroup
groupadd supergroup

# Add hbase in supergroup
usermod -a -G supergroup hbase
status=$?
if [ $status -ne 0 ];then
        echo "Error: Not able to add user 'hbase' in 'supergroup' : $status"
        exit $status
fi

# Add mapred user in supergroup
usermod -a -G supergroup mapred
status=$?
if [ $status -ne 0 ];then
        echo "Error: Not able to add user 'mapred' in 'supergroup' : $status"
        exit $status
fi

# Add hive in supergroup
usermod -a -G supergroup hive
status=$?
if [ $status -ne 0 ];then
        echo "Error: Not able to add user 'hive' in 'supergroup' : $status"
        exit $status
fi

# Add zookeeper in supergroup
usermod -a -G supergroup zookeeper
status=$?
if [ $status -ne 0 ];then
        echo "Error: Not able to add user 'zookeeper' in 'supergroup' : $status"
        exit $status
fi

# Add oozie in supergroup
usermod -a -G supergroup oozie
status=$?
if [ $status -ne 0 ];then
        echo "Error: Not able to add user 'oozie' in 'supergroup' : $status"
        exit $status
fi

# Add hdfs in supergroup
usermod -a -G supergroup hdfs
status=$?
if [ $status -ne 0 ];then
	echo "Error: Not able to add user 'hdfs' in 'supergroup' : $status"
        exit $status
fi
