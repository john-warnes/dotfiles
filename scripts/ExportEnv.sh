#!/bin/bash

set -a

function help {
cat <<EOF
    Usage: $0 [env file]

    -h|--help                    Display this text.
EOF
exit
}

POSITIONAL_ARGS=()

while (( "$#" )); do
    case "$1" in
    -?|-h|--help)
        shift 1
        help
    ;;
    --) # end argument parsing
        shift
        break
    ;;
    -*|--*=) # unsupported flags
        echo "Error: Unsupported flag $1" >&2
        help
        exit 1
    ;;
    *) # preserve positional arguments
        POSITIONAL_ARGS+=("$1")
        shift
    ;;
    esac
done


# set positional arguments in their proper place
eval set -- "${POSITIONAL_ARGS[@]}"
# echo "Postional Args: ${POSITIONAL_ARGS[@]}"

input=${POSITIONAL_ARGS[0]}

# Check if we have at least one
[[ ${#POSITIONAL_ARGS[@]} < 1 ]] && help

for i in "${POSITIONAL_ARGS[@]}"; do
    echo "Adding environment variables from \`$input\`"
    while read -r line; do 
        [[ $line =~ ^\s*#.* ]] && continue
        [[ -z "$line" ]] && continue
        export "$line";
    done < $input
done


set +a

#while IFS== read -r key value; do
#  printf -v "$key" %s "$value" && export "$key"
#done

#set -a
#source $1
#set +a

