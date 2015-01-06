# !/bin/bash

# Check for proper number of command line args.
EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {CONFIG_PROP_FILE}"
  exit $E_BADARGS
fi

CONFIG_PROP_FILE=$1
HOST_COUNT_PROP="host_count"

#remove existing property file
rm -f $CONFIG_PROP_FILE

echo -e "# Cloudera Cluster Installation Configuration Properties\n" > $CONFIG_PROP_FILE

echo cluster_name=ML-Test-Cluster >> $CONFIG_PROP_FILE

echo host_count=3 >> $CONFIG_PROP_FILE

echo host_name_1=v-ng-01f8.persistent.co.in >> $CONFIG_PROP_FILE

echo host_ip_1=10.222.116.161 >> $CONFIG_PROP_FILE

echo host_name_2=v-ng-01f9.persistent.co.in >> $CONFIG_PROP_FILE

echo host_ip_2=10.222.116.85 >> $CONFIG_PROP_FILE

echo host_name_3=v-ng-01fa.persistent.co.in >> $CONFIG_PROP_FILE

echo host_ip_3=10.222.116.163 >> $CONFIG_PROP_FILE

echo ntp_server_ip=10.77.224.101 >> $CONFIG_PROP_FILE
