# !/bin/bash

# Check for proper number of command line args.
EXPECTED_ARGS=4
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {SOURCE_PROPERTY_FILE} {SOURCE_PROPERTY_NAME} {TARGET_PROPERTY_FILE} {TARGET_PROPERTY_NAME}"
  exit $E_BADARGS
fi

SOURCE_PROPERTY_FILE=$1
SOURCE_PROPERTY_NAME=$2
TARGET_PROPERTY_FILE=$3
TARGET_PROPERTY_NAME=$4

prop_value=`grep -i $SOURCE_PROPERTY_NAME $SOURCE_PROPERTY_FILE | cut -f2 -d'='`

echo $TARGET_PROPERTY_NAME=$prop_value >> $TARGET_PROPERTY_FILE