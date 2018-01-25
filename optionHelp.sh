#!/bin/bash
E_BADARGS=65
MIN_EXPECTED_ARGS=1
IDWSSOTOKEN=""
response=[]

simple_usage(){
  echo "USAGE:  "
}

detailed_usage(){
  echo "Deatiled USAGE:"
}

check_options(){
  if [ "$1" == "-h" -o "$1" == "--help" ]
  then
    detailed_usage $1
  else
    echo "Use '-h' or '--help' to get help."
  fi
}

main(){
  check_options "$@"
}

# Start the execution.
main "$@"
