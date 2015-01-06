#!/sbin/bash
#This file will take the name for the file parts as an argument and will return the part file names as a list
PARTS_NAME=$1
BASE_DIR=`pwd`
BASE_ROLE_FILE_DIR=roleFileParts
if [ "$PARTS_NAME" == "HOST" ]; then
   for FILE in $BASE_ROLE_FILE_DIR/*.part
   do
     echo $BASE_DIR/$FILE
   done

elif [ "$PARTS_NAME" == "HBASE" ]; then
   for FILE in $BASE_ROLE_FILE_DIR/hbaseFiles/*.part
   do
     echo $BASE_DIR/$FILE
   done
elif [ "$PARTS_NAME" == "HDFS" ]; then
   for FILE in $BASE_ROLE_FILE_DIR/hdfsFiles/*.part
   do
     echo $BASE_DIR/$FILE
   done
elif [ "$PARTS_NAME" == "HIVE" ]; then
   for FILE in $BASE_ROLE_FILE_DIR/hiveFiles/*.part
   do
     echo $BASE_DIR/$FILE
   done
elif [ "$PARTS_NAME" == "OOZIE" ]; then
   for FILE in $BASE_ROLE_FILE_DIR/oozieFiles/*.part
   do
     echo $BASE_DIR/$FILE
   done
elif [ "$PARTS_NAME" == "ZOOKEEPER" ]; then
   for FILE in $BASE_ROLE_FILE_DIR/zkFiles/*.part
   do
     echo $BASE_DIR/$FILE
   done
elif [ "$PARTS_NAME" == "MAPREDUCE" ]; then
   for FILE in $BASE_ROLE_FILE_DIR/mrFiles/*.part
   do
     echo $BASE_DIR/$FILE
   done
elif [ "$PARTS_NAME" == "MONITOR_SERVICE" ]; then
   for FILE in $BASE_ROLE_FILE_DIR/monitorServiceFiles/*.part
   do
     echo $BASE_DIR/$FILE
   done
fi
