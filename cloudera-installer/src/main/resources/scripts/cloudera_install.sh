# !/bin/bash

sleep 10

EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -lt $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {CONFIG_PROP_FILE}"
  exit $E_BADARGS
fi

CONFIG_PROP_FILE=$1

SCRIPT_PATH="$(readlink -f ${BASH_SOURCE[0]})"
SCRIPT_DIR="$(dirname $SCRIPT_PATH)"

cd $SCRIPT_DIR

source ./env.props
status=$?
if [ $status -ne 0 ]; then
	echo "Error: Unable to source the property file : env.props : $status"
	exit $status
fi


# Read Properties
source $CONFIG_PROP_FILE
status=$?
if [ $status -ne 0 ]; then
	echo "Error: Unable to source the property file : $CONFIG_PROP_FILE : $status"
	exit $status
fi

#kill -9 `ps ax | grep cloudera-installer | awk '{print $1}'`
# Optional argument check
if [ ! -z "$2" ]; then
	kill -KILL ${PPID}
fi

# Install ntpd service
yum -y install ntp*
status=$?

if [ $status -ne 0 ]; then
        echo ' '
        echo "Error : Unable to install ntpd components. Installation aborted : $status"
        exit $status
fi


# Start ntpd service
# service ntpd stop

#Capture user input
#sh check_config.sh $CONFIG_PROP_FILE
#sh capture_preset_config_input.sh $CONFIG_PROP_FILE
#sh capture_config_input.sh $CONFIG_PROP_FILE
#status=$?

#if [ $status -ne 0 ]; then
#        echo "Error : Unable to capture configurarion inputs. Installation aborted : $status"
#        exit $status
#fi


# Start ntpd service
service ntpd start


# Install Cloudera packages & setup environment properties on Master & Child Nodes
echo Cloudera Installation and Environment Setup  [ This might take some time and appear non responsive ]

 
sh environment_setup.sh $CONFIG_PROP_FILE $REST_PROP_FILE
status=$?

if [ $status -ne 0 ]; then
        echo ' '
        echo "Error : Unable to install Cloudera components. Installation aborted : $status"
        exit $status
else
        echo -ne \\r
        echo Cloudera Installation and Environment Setup ... [ "##################################################" ] 100%
fi

#echo "This shouldn't be printed : $status"
#echo $status

# Copy database info to configuration property file
echo -n Creating Database Properties ... [ "#####" ] 10%

sh create_db_config.sh $CONFIG_PROP_FILE $DB_PROP_FILE
status=$?

if [ $status -ne 0 ]; then
	echo ' '
        echo "Error : Unable to create database properties. Installation aborted : $status"
        exit $status
else
	echo -ne \\r
	echo Creating Database Properties ... [ "##################################################" ] 100%
fi


# Create Hive DB & Roles
sh hive_db_create.sh $GENERATED_PASSWORD_FILE
status=$?

if [ $status -ne 0 ]; then
        echo "Error : Unable to create Hive database. Installation aborted : $status"
        exit $status
else
        echo Creating Hive Database ... [ "##################################################" ] 100%
fi


# Create Deployment Descriptor
echo -n Creating Deployment Descriptor ... [ "#####" ] 10%

sh deployment/create_deployment_desc.sh $CONFIG_PROP_FILE
status=$?

if [ $status -ne 0 ]; then
	echo ' '
        echo "Error : Unable to create Deployment Descriptor. Installation aborted : $status"
        exit $status
else
	echo -ne \\r
	echo Creating Deployment Descriptor ... [ "##################################################" ] 100%
fi


MANAGER_HOST=$host_ip_1
CLUSTER_NAME=$cluster_name


# Check Manager startup
sh check_manager_startup.sh $MANAGER_HOST
status=$?

if [ $status -ne 0 ]; then
        echo "Error : Unable to start Cloudera Manager. Installation aborted : $status"
        exit $status
fi


# Import Deployment Descriptor
sh import_deployment_desc.sh $MANAGER_HOST $CLUSTER_NAME @$DEPLOYMENT_DESCRIPTOR_FILE
status=$?

if [ $status -ne 0 ]; then
        echo "Error : Unable to import Deployment Descriptor. Installation aborted : $status"
        exit $status
fi


# Trigger Parcel Download
echo -n Triggering Download ... [ "#####" ] 10%
sleep 30
sh execute_sync_command.sh POST $MANAGER_HOST clusters/$CLUSTER_NAME/parcels/products/CDH/versions/$CLOUDERA_VERSION/commands/cancelDistribution
status=$?

if [ $status -ne 0 ]; then
        echo ' '
        echo "Error : Unable to trigger download. Installation aborted : $status"
        exit $status
else
	sleep 20
        echo -ne \\r
        echo Triggering Download ... [ "##################################################" ] 100%
fi

# Check Parcel Download
sh check_deployment_stage.sh $MANAGER_HOST $CLUSTER_NAME "DOWNLOADING"
status=$?

if [ $status -ne 0 ]; then
        echo "Error : Parcel Download Failed. Check network connection & try again. Installation aborted : $status"
        exit $status
fi


# Trigger Parcel Distribution
echo -n Triggering Distribution ... [ "#####" ] 10%
sleep 20
sh execute_sync_command.sh POST $MANAGER_HOST clusters/$CLUSTER_NAME/parcels/products/CDH/versions/$CLOUDERA_VERSION/commands/startDistribution
status=$?

if [ $status -ne 0 ]; then
        echo ' '
        echo "Error : Unable to trigger distribution. Installation aborted : $status"
        exit $status
else
        sleep 20
	echo -ne \\r
        echo Triggering Distribution ... [ "##################################################" ] 100%
fi


# Check Parcel Distribution
sh check_deployment_stage.sh $MANAGER_HOST $CLUSTER_NAME "DISTRIBUTING"
status=$?

if [ $status -ne 0 ]; then
        echo "Error : Parcel Distribution Failed. Check network connection & try again. Installation aborted : $status"
        exit $status
fi

sleep 5

# Activate deployment
echo -n Activating Deployment ... [ "#####" ] 10%
sh execute_sync_command.sh POST $MANAGER_HOST clusters/$CLUSTER_NAME/parcels/products/CDH/versions/$CLOUDERA_VERSION/commands/activate
status=$?

if [ $status -ne 0 ]; then
	echo ' '
        echo "Error : Unable to activate deployment. Try manually from web console. Installation aborted : $status"
        exit $status
else
        echo -ne \\r
        echo Activating Deployment ... [ "##################################################" ] 100%
	sleep 20
fi

# Format HDFS
sh execute_async_command.sh "HDFS Format" POST $MANAGER_HOST clusters/$CLUSTER_NAME/services/hdfs1/roleCommands/hdfsFormat '{"items":["hdfs1-NAMENODE-1"]}'


# Deploy Client Config
sh execute_async_command.sh "Client Config Deployment" POST $MANAGER_HOST clusters/$CLUSTER_NAME/commands/deployClientConfig


# Execute scripts on all nodes for adding users to supergroup and export ZOO_DATADIR_AUTOCREATE_DISABLE
echo -n Adding Users to Supergroup ... [ "#####" ] 10%
sh add_users_in_supergroup.sh $CONFIG_PROP_FILE
status=$?

if [ $status -ne 0 ]; then
        echo ' '
        echo "Error : Unable to add users to supergroup. Installation aborted : $status"
        exit $status
else
        echo -ne \\r
        echo Adding Users to Supergroup ... [ "##################################################" ] 100%
fi


# Start Cloudera Cluster
sh execute_async_command.sh "Cloudera Cluster Startup" POST $MANAGER_HOST clusters/$CLUSTER_NAME/commands/start
status=$?

if [ $status -ne 0 ]; then
        echo "Error : Unable to verify installation & start Cluster. Try manually from web console : $status"
        exit $status
fi


# Start Cloudera Cluster
sh execute_async_command.sh "Monitoring Services Startup" POST $MANAGER_HOST cm/service/commands/start
status=$?

if [ $status -ne 0 ]; then
        echo "Error : Unable to start Monitoring Service. Try manually from web console : $status"
        exit $status
fi

echo -e "\n##################################### CLOUDERA INSTALLED SUCCESSFULLY #########################################\n"
