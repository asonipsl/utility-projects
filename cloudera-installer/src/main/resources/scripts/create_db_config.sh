# !/bin/bash

# Check for proper number of command line args.
EXPECTED_ARGS=2
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {CONFIG_PROP_FILE} {SOURCE_PROP_FILE}"
  exit $E_BADARGS
fi

CONFIG_PROP_FILE=$1
SOURCE_PROP_FILE=$2

# Check if db properties file exists
if [ ! -f $SOURCE_PROP_FILE ]; then
	echo "Database Properies file $SOURCE_PROP_FILE doesn't exist"
	exit 1
fi

echo -e "\n# Postgres Database Properties\n" >> $CONFIG_PROP_FILE

# Service Monitor Properties
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.SERVICEMONITOR.db.host" $CONFIG_PROP_FILE "servicemonitor_db_host"
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.SERVICEMONITOR.db.name" $CONFIG_PROP_FILE "servicemonitor_db_name"
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.SERVICEMONITOR.db.user" $CONFIG_PROP_FILE "servicemonitor_db_user"
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.SERVICEMONITOR.db.password" $CONFIG_PROP_FILE "servicemonitor_db_password"

# Activity Monitor Properties
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.ACTIVITYMONITOR.db.host" $CONFIG_PROP_FILE "activitymonitor_db_host"
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.ACTIVITYMONITOR.db.name" $CONFIG_PROP_FILE "activitymonitor_db_name"
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.ACTIVITYMONITOR.db.user" $CONFIG_PROP_FILE "activitymonitor_db_user"
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.ACTIVITYMONITOR.db.password" $CONFIG_PROP_FILE "activitymonitor_db_password"

# Host Monitor Properties
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.HOSTMONITOR.db.host" $CONFIG_PROP_FILE "hostmonitor_db_host"
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.HOSTMONITOR.db.name" $CONFIG_PROP_FILE "hostmonitor_db_name"
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.HOSTMONITOR.db.user" $CONFIG_PROP_FILE "hostmonitor_db_user"
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.HOSTMONITOR.db.password" $CONFIG_PROP_FILE "hostmonitor_db_password"

# Reports Manager Properties
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.REPORTSMANAGER.db.host" $CONFIG_PROP_FILE "reportsmanager_db_host"
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.REPORTSMANAGER.db.name" $CONFIG_PROP_FILE "reportsmanager_db_name"
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.REPORTSMANAGER.db.user" $CONFIG_PROP_FILE "reportsmanager_db_user"
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.REPORTSMANAGER.db.password" $CONFIG_PROP_FILE "reportsmanager_db_password"


# Navigator Properties
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.NAVIGATOR.db.host" $CONFIG_PROP_FILE "navigator_db_host"
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.NAVIGATOR.db.name" $CONFIG_PROP_FILE "navigator_db_name"
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.NAVIGATOR.db.user" $CONFIG_PROP_FILE "navigator_db_user"
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.NAVIGATOR.db.password" $CONFIG_PROP_FILE "navigator_db_password"

# Hive Metastore Properties
sh read_db_property.sh $SOURCE_PROP_FILE "com.cloudera.cmf.SERVICEMONITOR.db.host" $CONFIG_PROP_FILE "hivemetastore_db_host"
echo hivemetastore_db_name=hive >> $CONFIG_PROP_FILE
echo hivemetastore_db_user=hive >> $CONFIG_PROP_FILE
echo hivemetastore_db_password=hIve123 >> $CONFIG_PROP_FILE
