#!/bin/bash

ADB=~/Android/Sdk/platform-tools/adb
PREFIX=screenshot_
CONTINUOUS=false
SLEEPMS=0.1

function help {
    cat <<EOF
    Usage: $0 [options]

    -c | --continuous              Continuous take screenshots till '^C'
    -h | --help                    Display this text.

EOF
    exit
}

function ctrl_c() {
    echo "** Exiting **"
    exit
}

POSITIONAL_ARGS=""

while (("$#")); do
    case "$1" in
    -'?' | -h | --help)
        shift 1
        help
        ;;
    -c | --continuous)
        CONTINUOUS=true
        shift 1
        echo "Taking a screenshot every ${SLEEPMS}s"
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
        POSITIONAL_ARGS="$POSITIONAL_ARGS \"$1\""
        shift
        ;;
    esac
done

# set positional arguments in their proper place
eval set -- "$POSITIONAL_ARGS"

echo "Saving to '$PWD/'"

while true; do
    FILE=$PREFIX$(date +"%Y-%m-%dT%H:%M:%S.%N").png
    echo "$FILE"

    # DEBUG
    # echo "$ADB" exec-out screencap -p $@ '>' $FILE
    $ADB  exec-out screencap -p $@ > $FILE

    if [ ! $CONTINUOUS == true ]; then
        break
    fi

    sleep $SLEEPMS
done

