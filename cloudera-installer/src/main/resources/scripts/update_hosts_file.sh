#!/bin/bash
# This script will update the /etc/hosts file

EXPECTED_ARGS=2
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {IP} {HOSTNAME}"
  exit $E_BADARGS
fi

IP=$1
HOSTNAME=$2
status=`cat /etc/hosts | grep "$HOSTNAME"`
if [ $? -ne 0 ]; then
	echo "$IP $HOSTNAME" >> /etc/hosts
	status=$?
        if [ $? -ne 0 ]; then
              	echo "Error: Unable to update /etc/hosts file: $status"
		exit $status
	fi
fi
