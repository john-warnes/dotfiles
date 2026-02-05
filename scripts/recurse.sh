#!/usr/bin/env bash

if [[ -z "$1" ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  echo "USAGE: recurse.sh <command>"

  echo "  Will run <command> in the current working directory and also in all sub directories"
  exit 1
fi

set -o nounset         # Treat unset variables as an error

pwd=$(pwd)             # Starting point; it is important that you start at the right place
dirs=$(find . -type d) # Will save the sub/directory tree in var

# Save original IFS and restore it after
OLD_IFS=$IFS
IFS=$'\n'

for dir in $dirs; do
  echo ""
  echo "$dir"
  if ! cd "$dir"; then
    echo "ERROR: Unable to change to directory: $dir" >&2
    continue
  fi
  "$@"                   # Run the command
  cd "$pwd" || exit 1    # Go back to start, exit if fails
done

IFS=$OLD_IFS
