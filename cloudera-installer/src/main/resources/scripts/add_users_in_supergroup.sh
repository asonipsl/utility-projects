#!/sbin/bash
# This script adds cloudera users in its supergroup

counter=1
while IFS= read -r line
do
	HOST_IP=`echo $line | awk '{print $1}'`
	
	if [ $counter -eq 1 ]; then
		sh create_users_and_supergroup.sh
	else
		ssh $HOST_IP "bash -s" -- < create_users_and_supergroup.sh
	fi

	status=$?
        if [ $status -ne 0 ];then
                echo "Error: Not able to add users in 'supergroup' on host : $HOST_IP :: status : $status"
                exit $status
        fi

	
	(( counter++ ))	
done < "hostFile.tmp"

# Clean up
rm -f "hostFile.tmp"
exit 0
