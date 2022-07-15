#!/bin/bash

ADB=~/Android/Sdk/platform-tools/adb

function help {
    cat <<EOF
    Usage: $0 [options]

    -h|--help                    Display this text.
    -c|--connect [ip address]    Connect to the Android device
    -d|--disconnect              Disconnect from all Android devices
    -l|--logcat [logcat params]  Output the logcat for connect Android device
    -s|--shell                   Connect to ADB shell on device

EOF
    exit
}

POSITIONAL_ARGS=""

while (("$#")); do
    case "$1" in
    -c | --connect)
        IP=$2
        shift 2

        if [[ $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "Ip detected as" $IP
        else
            echo "Error: unknown ip address format: $IP" >&2
            exit 1
        fi
        # hope it's a IP address

        $ADB tcpip 5555
        $ADB connect $IP:5555
        exit
        ;;
    -d | --disconnect)
        $ADB disconnect
        shift 1
        exit
        ;;
    -l | --logcat)
        shift 1
        $ADB logcat $@
        exit
        ;;
    -s | --shell)
        shift 1
        $ADB shell $@
        exit
        ;;
    -? | -h | --help)
        shift 1
        help
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
        POSITIONAL_ARGS="$POSITIONAL_ARGS $1"
        shift
        ;;
    esac
done

# set positional arguments in their proper place
eval set -- "$POSITIONAL_ARGS"

