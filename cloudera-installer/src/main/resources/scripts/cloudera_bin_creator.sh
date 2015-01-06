#!/bin/bash

EXPECTED_ARGS=2
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {version} {release}"
  exit $E_BADARGS
fi

version=$1
release=$2

_script="$(readlink -f ${BASH_SOURCE[0]})"
SCRIPTS_BASE_DIR="$(dirname $_script)"
cd $SCRIPTS_BASE_DIR/..
HOME_DIR=`pwd`
cd $SCRIPTS_BASE_DIR

cp cloudera_self_extractor.sh $HOME_DIR/cloudera-installer-$version-$release.bin
cd $HOME_DIR
tar czf - diagnostics/ scripts/ >> cloudera-installer-$version-$release.bin
