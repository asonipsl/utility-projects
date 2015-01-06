# !/bin/bash

# Check for proper number of command line args.
EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {GENERATED_PASSWORD_FILE}"
  exit $E_BADARGS
fi

GENERATED_PASSWORD_FILE=$1

echo -e "\n\n ##### AUTOMATED DB CREATION IN PROGRESS. DON'T TYPE ANYTHING UNTIL COMPLETE ##### \n\n"

# retrieve password from password file
#read -r PWD < $GENERATED_PASSWORD_FILE
PWD=`sed -n '1p' $GENERATED_PASSWORD_FILE | awk '{print $1}'`

# spawn postgres shell and enter password
/usr/bin/expect <<EOD
spawn sudo -u postgres psql -U cloudera-scm -p 7432 -d postgres
expect "password"
send "$PWD\n"
expect eof

# create role in postgres shell
send "CREATE ROLE hive LOGIN PASSWORD 'hIve123';\n"
expect eof

# create db in postgres shell
send "CREATE DATABASE hive OWNER hive ENCODING 'UTF8';\n"
expect eof

# end expect
interact
EOD
