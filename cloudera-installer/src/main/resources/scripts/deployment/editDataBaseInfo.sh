#!/sbin/bash
#This script will edit the hive metadata in deployment descriptor

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


HIVE_HOST=`echo $hivemetastore_db_host | awk -F':' '{print $1}'`
HIVE_PORT=`echo $hivemetastore_db_host | awk -F':' '{print $2}'`

SED_CMD_CLUSTER_NAME=s/{ML_CLUSTER_1}/$cluster_name/g
SED_CMD_HIVE_HOSTNAME=s/{HIVE_METASTORE_HOSTNAME}/$HIVE_HOST/g
SED_CMD_HIVE_PORT=s/{HIVE_METASTORE_PORT}/$HIVE_PORT/g
SED_CMD_HIVE_DBNAME=s/{HIVE_DB_NAME}/$hivemetastore_db_name/g
SED_CMD_HIVE_DBPSWD=s/{HIVE_DB_PASSWORD}/$hivemetastore_db_password/g
SED_CMD_HIVE_DBUSER=s/{HIVE_DB_USER}/$hivemetastore_db_user/g
SED_CMD_AMON_HOSTNAME=s/{ACTIVITYMONITOR_DB_HOST}/$activitymonitor_db_host/g
SED_CMD_AMON_DBNAME=s/{ACTIVITYMONITOR_DB_NAME}/$activitymonitor_db_name/g
SED_CMD_AMON_DBPSWD=s/{ACTIVITYMONITOR_DB_PSWD}/$activitymonitor_db_password/g
SED_CMD_AMON_DBUSER=s/{ACTIVITYMONITOR_DB_USER}/$activitymonitor_db_user/g
SED_CMD_HMON_HOSTNAME=s/{HOSTMONITOR_DB_HOST}/$hostmonitor_db_host/g
SED_CMD_HMON_DBNAME=s/{HOSTMONITOR_DB_NAME}/$hostmonitor_db_name/g
SED_CMD_HMON_DBPSWD=s/{HOSTMONITOR_DB_PSWD}/$hostmonitor_db_password/g
SED_CMD_HMON_DBUSER=s/{HOSTMONITOR_DB_USER}/$hostmonitor_db_user/g
SED_CMD_SMON_HOSTNAME=s/{SERVICEMONITOR_DB_HOST}/$servicemonitor_db_host/g
SED_CMD_SMON_DBNAME=s/{SERVICEMONITOR_DB_NAME}/$servicemonitor_db_name/g
SED_CMD_SMON_DBPSWD=s/{SERVICEMONITOR_DB_PSWD}/$servicemonitor_db_password/g
SED_CMD_SMON_DBUSER=s/{SERVICEMONITOR_DB_USER}/$servicemonitor_db_user/g

sed -i $SED_CMD_CLUSTER_NAME deploy_desc.json
sed -i $SED_CMD_HIVE_HOSTNAME deploy_desc.json
sed -i $SED_CMD_HIVE_PORT deploy_desc.json
sed -i $SED_CMD_HIVE_DBNAME deploy_desc.json
sed -i $SED_CMD_HIVE_DBPSWD deploy_desc.json
sed -i $SED_CMD_HIVE_DBUSER deploy_desc.json
sed -i $SED_CMD_AMON_HOSTNAME deploy_desc.json
sed -i $SED_CMD_AMON_DBNAME deploy_desc.json
sed -i $SED_CMD_AMON_DBPSWD deploy_desc.json
sed -i $SED_CMD_AMON_DBUSER deploy_desc.json
sed -i $SED_CMD_HMON_HOSTNAME deploy_desc.json
sed -i $SED_CMD_HMON_DBNAME deploy_desc.json
sed -i $SED_CMD_HMON_DBPSWD deploy_desc.json
sed -i $SED_CMD_HMON_DBUSER deploy_desc.json
sed -i $SED_CMD_SMON_HOSTNAME deploy_desc.json
sed -i $SED_CMD_SMON_DBNAME deploy_desc.json
sed -i $SED_CMD_SMON_DBPSWD deploy_desc.json
sed -i $SED_CMD_SMON_DBUSER deploy_desc.json

exit 0
