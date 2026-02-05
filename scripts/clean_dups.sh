#!/usr/bin/env bash

# =rev=======================================================================
#          File: clean_dups.sh
#        Author: John Warnes, johnw@savagebee.org
#       Created: 04/25/2024 05:11:20 PM
#      Revision: 003
#      Modified: Wednesday, 4 February 2026
#       Version: 0.0.1
# ===========================================================================


# Use the current working directory by default
DIRECTORY=$(pwd)
HASH=sha256sum
POSITIONAL_ARGS=()

function help {
    cat <<EOF
    Usage: $0 [options]

        Checks given directory (or current if non passed) for duplicate files by content
        then deletes the newer of the files.

        defaults to using sha256 to check contents

         --sha1                    Use sha1 for hash
         --sha256                  Use sha256 for hash
         --sha512                  Use sha512 for hash
         --md5                     Use md5 for hash

    -h | --help                    Display this text.

EOF
    exit
}

while (("$#")); do
    case "$1" in
    -'?' | -h | --help)
        shift
        help
        ;;
    --sha1)
        HASH=sha1sum
        shift
        ;;
    --sha256)
        HASH=sha256sum
        shift
        ;;
    --sha512)
        HASH=sha512sum
        shift
        ;;
    --md5)
        HASH=md5sum
        shift
        ;;
    --) # end argument parsing
        shift
        break
        ;;
    -* | --*=) # unsupported flags
        echo "Error: Unsupported flag $1" >&2
        help
        exit 1
        ;;
    *) # preserve positional arguments
        POSITIONAL_ARGS+=( "$1" )
        shift
        ;;
    esac
done

# set positional arguments in their proper place
set -- "${POSITIONAL_ARGS[@]}"

# Check if a directory path is provided as a command-line argument
if [[ -n "$1" ]]; then
    DIRECTORY="$1"
fi

# Move to the directory containing the files
cd "$DIRECTORY" || {
    echo "Directory not found"
    exit 1
}

echo "Cleaning $DIRECTORY"

# Verify hash command exists
if ! command -v "$HASH" &> /dev/null; then
    echo "Error: $HASH command not found" >&2
    exit 1
fi

# Create an associative array to store file hashes
declare -A hashes

# Enable nullglob to handle empty directories
shopt -s nullglob

# Iterate over each file in the directory
for file in *; do

    # if file is a directory skip it
    if [[ -d "$file" ]]; then
        continue
    fi

    # Calculate the hash of the file
    hash=$($HASH "$file" | awk '{print $1}')

    # Check if the hash already exists in the array
    if [[ -n ${hashes[$hash]} ]]; then
        echo "Duplicate detected"

        # If it does, compare the timestamps of the current file and the existing file
        if [[ "$file" -nt "${hashes[$hash]}" ]]; then
            echo "    $file  (Deleted - newer)"
            echo "    ${hashes[$hash]}  (Kept - older)"

            # If the current file is newer, remove it and keep the older one
            rm "$file"
        else
            echo "    ${hashes[$hash]}  (Deleted - newer)"
            echo "    $file  (Kept - older)"

            # If the existing file is newer, remove it and keep the current file
            rm "${hashes[$hash]}"
            # Update the array with the current file's hash
            hashes[$hash]="$file"
        fi
    else
        # If the hash doesn't exist in the array, add it with the current file
        hashes[$hash]="$file"
    fi
done
