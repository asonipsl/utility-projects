#!/sbin/bash
# This script will create role files 

EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {CONFIG_PROP_FILE}"
  exit $E_BADARGS
fi

CONFIG_PROP_FILE=$1

# Read Properties
source $CONFIG_PROP_FILE
status=$?
if [ $status -ne 0 ]; then
        echo "Error: Unable to source the property file : $CONFIG_PROP_FILE : $status"
        exit $status
fi


rm -rf roleFileParts
mkdir roleFileParts
mkdir roleFileParts/hbaseFiles
mkdir roleFileParts/hdfsFiles
mkdir roleFileParts/hiveFiles
mkdir roleFileParts/oozieFiles
mkdir roleFileParts/zkFiles
mkdir roleFileParts/mrFiles
mkdir roleFileParts/monitorServiceFiles

for (( c=1; c<=$host_count; c++ ))
do
   varHostName="host_name_$c"
   varHostIp="host_ip_$c"
   #echo Creating config file parts for host id : ${!varHostName} , host IP : ${!varHostIp}
  
   # sed commonds for substitution
   SED_CMD_HOST_IP=s/{HOSTIP}/${!varHostIp}/g
   SED_CMD_ROLECOUNT=s/{ROLECOUNT}/$c/g
   SED_CMD_HOSTID=s/{HOSTID}/${!varHostName}/g
   SED_CMD_ZK_SERVER_ID=s/{SERVERID}/$c/g

   # Create common part files for each host
   sed -e $SED_CMD_HOST_IP statFiles/hostInfo.stat > hostInfo.tmp
   sed -e $SED_CMD_HOSTID hostInfo.tmp > roleFileParts/hostInfo_$c.part
   sed -e $SED_CMD_ROLECOUNT statFiles/hbase/hbaseRole_RS.stat > hbaseRole_RS.tmp
   sed -e $SED_CMD_HOSTID hbaseRole_RS.tmp > roleFileParts/hbaseFiles/hbaseRole_REGIONSERVER_$c.part
   sed -e $SED_CMD_ROLECOUNT statFiles/hdfs/hdfsRole_DATANODE.stat > hdfsRole_DATANODE.tmp
   sed -e $SED_CMD_HOSTID hdfsRole_DATANODE.tmp > roleFileParts/hdfsFiles/hdfsRole_DATANODE_$c.part
   sed -e $SED_CMD_ROLECOUNT statFiles/hive/hiveRole_GATEWAY.stat > hiveRole_GATEWAY.tmp
   sed -e $SED_CMD_HOSTID hiveRole_GATEWAY.tmp > roleFileParts/hiveFiles/hiveRole_GATEWAY_$c.part
   sed -e $SED_CMD_ROLECOUNT statFiles/mapreduce/mrRole_TT.stat > mrRole_TT.tmp
   sed -e $SED_CMD_HOSTID mrRole_TT.tmp > roleFileParts/mrFiles/mrRole_TT_$c.part

   if [ $c -eq 1 ];then

	# Roles specific only to first node
	sed -e $SED_CMD_ROLECOUNT statFiles/hbase/hbaseRole_MASTER.stat > hbaseRole_MASTER.tmp
        sed -e $SED_CMD_HOSTID hbaseRole_MASTER.tmp > roleFileParts/hbaseFiles/hbaseRole_MASTER.part
	sed -e $SED_CMD_ROLECOUNT statFiles/hdfs/hdfsRole_NAMENODE.stat > hdfsRole_NAMENODE.tmp
        sed -e $SED_CMD_HOSTID hdfsRole_NAMENODE.tmp > roleFileParts/hdfsFiles/hbaseRole_NAMENODE.part
	sed -e $SED_CMD_ROLECOUNT statFiles/hive/hiveRole_METASTORE.stat > hiveRole_METASTORE.tmp
        sed -e $SED_CMD_HOSTID hiveRole_METASTORE.tmp > roleFileParts/hiveFiles/hiveRole_METASTORE.part
	sed -e $SED_CMD_ROLECOUNT statFiles/oozie/oozieRole_OOZIE_SERVER.stat > oozieRole_OOZIE_SERVER.tmp
        sed -e $SED_CMD_HOSTID oozieRole_OOZIE_SERVER.tmp > roleFileParts/oozieFiles/oozieRole_OOZIE_SERVER.part
        sed -e $SED_CMD_ROLECOUNT statFiles/zookeeper/zookeeperRole_SERVER.stat > zookeeperRole_SERVER.tmp
        sed -e $SED_CMD_HOSTID zookeeperRole_SERVER.tmp > zookeeperRole_SERVER_2.tmp
        sed -e $SED_CMD_ZK_SERVER_ID zookeeperRole_SERVER_2.tmp > roleFileParts/zkFiles/zookeeperRole_SERVER_$c.part
	sed -e $SED_CMD_ROLECOUNT statFiles/mapreduce/mrRole_JT.stat > mrRole_JT.tmp
        sed -e $SED_CMD_HOSTID mrRole_JT.tmp > roleFileParts/mrFiles/mrRole_JT.part

	# Monitor service roles
	sed -e $SED_CMD_ROLECOUNT statFiles/monitorService/role_ACTIVITYMONITOR.stat > role_ACTIVITYMONITOR.tmp
        sed -e $SED_CMD_HOSTID role_ACTIVITYMONITOR.tmp > roleFileParts/monitorServiceFiles/role_ACTIVITYMONITOR.part
	sed -e $SED_CMD_ROLECOUNT statFiles/monitorService/role_ALERTPUBLISHER.stat > role_ALERTPUBLISHER.tmp
        sed -e $SED_CMD_HOSTID role_ALERTPUBLISHER.tmp > roleFileParts/monitorServiceFiles/role_ALERTPUBLISHER.part
	sed -e $SED_CMD_ROLECOUNT statFiles/monitorService/role_EVENTSERVER.stat > role_EVENTSERVER.tmp
        sed -e $SED_CMD_HOSTID role_EVENTSERVER.tmp > roleFileParts/monitorServiceFiles/role_EVENTSERVER.part
	sed -e $SED_CMD_ROLECOUNT statFiles/monitorService/role_HOSTMONITOR.stat > role_HOSTMONITOR.tmp
        sed -e $SED_CMD_HOSTID role_HOSTMONITOR.tmp > roleFileParts/monitorServiceFiles/role_HOSTMONITOR.part
	sed -e $SED_CMD_ROLECOUNT statFiles/monitorService/role_SERVICEMONITOR.stat > role_SERVICEMONITOR.tmp
        sed -e $SED_CMD_HOSTID role_SERVICEMONITOR.tmp > roleFileParts/monitorServiceFiles/role_SERVICEMONITOR.part

   elif [ $c -eq 2 ];then

	# Roles specific only to second node
        sed -e $SED_CMD_ROLECOUNT statFiles/hdfs/hdfsRole_SECONDARYNAMENODE.stat > hdfsRole_SECONDARYNAMENODE.tmp
        sed -e $SED_CMD_HOSTID hdfsRole_SECONDARYNAMENODE.tmp > roleFileParts/hdfsFiles/hdfsRole_SECONDARYNAMENODE.part
        sed -e $SED_CMD_ROLECOUNT statFiles/hive/hiveRole_GATEWAY.stat > hiveRole_GATEWAY.tmp
        sed -e $SED_CMD_HOSTID hiveRole_GATEWAY.tmp > roleFileParts/hiveFiles/hiveRole_GATEWAY_$c.part

	if [ $host_count -ge 3 ];then
		# If only there are 3 more than 3 nodes are present
		sed -e $SED_CMD_ROLECOUNT statFiles/zookeeper/zookeeperRole_SERVER.stat > zookeeperRole_SERVER.tmp
		sed -e $SED_CMD_HOSTID zookeeperRole_SERVER.tmp > zookeeperRole_SERVER_2.tmp
	        sed -e $SED_CMD_ZK_SERVER_ID zookeeperRole_SERVER_2.tmp > roleFileParts/zkFiles/zookeeperRole_SERVER_$c.part
	fi

   elif [ $c -eq 3 ];then

	# Roles specific only to third node
        sed -e $SED_CMD_ROLECOUNT statFiles/hdfs/hdfsRole_BALANCER.stat > hdfsRole_BALANCER.tmp
        sed -e $SED_CMD_HOSTID hdfsRole_BALANCER.tmp > roleFileParts/hdfsFiles/hdfsRole_BALANCER.part
        sed -e $SED_CMD_ROLECOUNT statFiles/zookeeper/zookeeperRole_SERVER.stat > zookeeperRole_SERVER.tmp
	sed -e $SED_CMD_HOSTID zookeeperRole_SERVER.tmp > zookeeperRole_SERVER_2.tmp
        sed -e $SED_CMD_ZK_SERVER_ID zookeeperRole_SERVER_2.tmp > roleFileParts/zkFiles/zookeeperRole_SERVER_$c.part

   fi

   # Remove the temporary files
   rm -f *.tmp

done 

exit 0
