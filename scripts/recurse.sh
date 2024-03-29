#!/bin/bash

if [[ -z "$1" ]]; then
  echo "USAGE: recurse.sh <command>"

  echo "  Will run <command> in the current working directory and also in all sub directories"
  exit
fi

IFS=$'\n'

set -o nounset         # Treat unset variables as an error

pwd=$(pwd)             # Starting point; it is important that you start at the right place
dirs=$(find . -type d) # Will save the sub/directory tree in var

for dir in $dirs; do
  echo ""
  echo "$dir"
  cd $dir              # Go into directory
  $@                   # Run the command
  cd $pwd              # Go back to start
done
