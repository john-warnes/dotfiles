#!/usr/bin/env bash

if [[ -z "${1-}" ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  echo "USAGE: recurse.sh <command>"
  echo "  Will run <command> in the current working directory and also in all sub directories"
  echo ""
  echo "  Wildcard support: quote glob patterns so the shell does not expand them early."
  echo "    Example: recurse.sh ls '*.txt'"
  echo "    Example: recurse.sh grep -r 'pattern' '*.log'"
  exit 0
fi

set -o nounset         # Treat unset variables as an error

start_dir=$(pwd)       # Starting point; it is important that you start at the right place
dirs=$(find . -mindepth 1 -type d -not -path '*/.*') # Sub/directory tree, excluding hidden dirs

# Detect if any argument contains unexpanded glob metacharacters (user must have quoted them)
has_glob=false
for arg in "$@"; do
  if [[ "$arg" == *[\*\?\[]* ]]; then
    has_glob=true
    break
  fi
done

# Save original IFS and restore it after
OLD_IFS=${IFS-}
IFS=$'\n'

for dir in $dirs; do
  echo ""
  echo "$dir"
  if ! cd "$dir"; then
    echo "ERROR: Unable to change to directory: $dir" >&2
    continue
  fi
  if $has_glob; then
    if ! bash -c "$*"; then    # Run with glob expansion in the current dir
      echo "ERROR: Command failed in: $dir" >&2
    fi
  else
    if ! "$@"; then            # Run the command
      echo "ERROR: Command failed in: $dir" >&2
    fi
  fi
  cd "$start_dir" || exit 1  # Go back to start, exit if fails
done

IFS=$OLD_IFS
