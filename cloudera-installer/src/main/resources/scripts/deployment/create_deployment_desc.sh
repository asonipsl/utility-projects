#!/sbin/bash
# This script will create deployment descriptor
# The script will return with exit code 1 if any of the script doesn't execute properly

EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {CONFIG_PROP_FILE}"
  exit $E_BADARGS
fi

CONFIG_PROP_FILE=$1

#echo "Creating deployment descriptor"

_script="$(readlink -f ${BASH_SOURCE[0]})"
SCRIPTS_BASE_DIR="$(dirname $_script)"
cd $SCRIPTS_BASE_DIR

# Create role files
sh updateHostInfoInRoleStats.sh $CONFIG_PROP_FILE
if [ $? -eq 0 ];then

	# Insert roles info in descriptor
	python editDeploymentDescriptor.py $SCRIPTS_BASE_DIR/data.json.stat
	if [ $? -eq 0 ];then
		
		# Update database info in descriptor
		sh editDataBaseInfo.sh $CONFIG_PROP_FILE
		if [ $? -eq 0 ];then
			exit 0
		else
			exit 1
		fi
	else
		exit 1
	fi
	#echo "Deployment descriptor created"
else
	exit 1
fi

