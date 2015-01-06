# !/bin/bash

# Check for proper number of command line args.
EXPECTED_ARGS=3
E_BADARGS=65
MAX_COUNT=490

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {HOST_IP} {CLUSTER_NAME} {PARCEL_STAGE}"
  exit $E_BADARGS
fi

HOST=$1
CLUSTER_NAME=$2
PARCEL_STAGE=$3
URL=http://$HOST:7180/api/v4/clusters/$CLUSTER_NAME/parcels/products/CDH/versions/4.6.0-1.cdh4.6.0.p0.26

# Status : {0 - Complete, 1 - In Progress, 2 - Error, 3 - Timed Out}

status=1
counter=0
prev_complete=0

# Check if parcel is downloaded
while [[ $status -eq 1  && $counter -lt $MAX_COUNT ]]
do
	response=`sh rest_call.sh GET $URL`
	#echo response=$response
	if [ ! -n "$response" ]; then
		echo Error : No response received
		status=2
                exit $status
	fi

	stage=`python parse_json.py "$response" "stage"`
	#echo stage=$stage
	if [ ! -n "$stage" ]; then
		echo Error : Unable to parse response
                status=2
                exit $status
        fi

	if [ "$stage" = "$PARCEL_STAGE" ]; then

		progress=`python parse_json.py "$response" "progress"`
		#echo progress=$progress
		total_progress=`python parse_json.py "$response" "totalProgress"`
		#echo total_progress=$total_progress
		complete_percent=$((progress*100/total_progress))
		#echo complete=$complete_percent

		if [ $complete_percent -gt 90 ]; then
                        echo -ne $PARCEL_STAGE Parcel ... [ "##############################################" ] 90%\\r
		elif [ $complete_percent -gt 80 ]; then
                        echo -ne $PARCEL_STAGE Parcel ... [ "##########################################" ] 80%\\r
		elif [ $complete_percent -gt 70 ]; then
                        echo -ne $PARCEL_STAGE Parcel ... [ "#####################################" ] 70%\\r
		elif [ $complete_percent -gt 60 ]; then
                        echo -ne $PARCEL_STAGE Parcel ... [ "################################" ] 60%\\r
		elif [ $complete_percent -gt 50 ]; then
                        echo -ne $PARCEL_STAGE Parcel ... [ "###########################" ] 50%\\r
		elif [ $complete_percent -gt 40 ]; then
                        echo -ne $PARCEL_STAGE Parcel ... [ "######################" ] 40%\\r
		elif [ $complete_percent -gt 30 ]; then
                        echo -ne $PARCEL_STAGE Parcel ... [ "#################" ] 30%\\r
		elif [ $complete_percent -gt 20 ]; then
                        echo -ne $PARCEL_STAGE Parcel ... [ "############" ] 20%\\r
		elif [ $complete_percent -gt 10 ]; then
                        echo -ne $PARCEL_STAGE Parcel ... [ "######" ] 10%\\r
		elif [ $complete_percent -ge 0 ]; then
                        echo -ne $PARCEL_STAGE Parcel ... [ "#" ] 0%\\r
		fi

	elif [[ "$PARCEL_STAGE" = "DOWNLOADING" ]] && [[ "$stage" = "DOWNLOADED" || "$stage" = "DISTRIBUTING" || "$stage" = "DISTRIBUTED" || "$stage" = "ACTIVATED" ]]; then
		# Download complete
		echo Downloading Parcel ... [ "##################################################" ] 100%
                status=0
		exit $status

	elif [[ "$PARCEL_STAGE" = ""DISTRIBUTING"" ]] && [[ "$stage" = "DISTRIBUTED" || "$stage" = "ACTIVATED" ]]; then
                # Distribution complete
                echo Distributing Complete ... [ "##################################################" ] 100%
                status=0
		exit $status

	elif ! [[ "$stage" = "DOWNLOADING" || "$stage" = "DOWNLOADED" || "$stage" = "DISTRIBUTING" || "$stage" = "DISTRIBUTED" || "$stage" = "ACTIVATED" ]]; then
		echo Invalid Parcel Stage : $stage
		status=2
		exit $status
	fi

	(( counter++ ))
	if [[ $counter -eq $MAX_COUNT ]]; then

		if [[ $((complete_percent-prev_complete)) -lt 5 ]]; then
			echo Error : $PARCEL_STAGE Operation timed out ...
			status=3
			exit $status
		else
			counter=0
			prev_complete=$complete_percent
			#echo prev_complete=$prev_complete
		fi
	fi

	sleep 20
done
