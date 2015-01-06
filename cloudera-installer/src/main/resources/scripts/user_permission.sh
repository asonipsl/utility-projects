#!/bin/bash

# user related permission
groupadd supergroup
usermod -a -G supergroup hbase
usermod -a -G supergroup mapred
usermod -a -G supergroup hive
usermod -a -G supergroup zookeeper
usermod -a -G supergroup oozie
usermod -a -G supergroup hdfs

echo export ZOO_DATADIR_AUTOCREATE_DISABLE=false >> /etc/profile
source /etc/profile
