#!/usr/bin/env bash

case "$OSTYPE" in
    solaris*) export OS="SOLARIS" ;;
    darwin*)  export OS="OSX" ;;
    linux*)   export OS="LINUX" ;;
    bsd*)     export OS="BSD" ;;
    cygwin*)  export OS="BABUN" ;;
    msys*)    export OS="WINDOWS" ;;
    *)        export OS="unknown: $OSTYPE" ;;
esac

if [[ $OS == "LINUX" ]]; then
    # IDs help ---> https://gitlab.com/zygoon/os-release-zoo
    if [[ -f /etc/os-release ]]; then
        # Read in a subshell to avoid polluting the environment
        _os_info=$(. /etc/os-release && echo "$PRETTY_NAME|$ID|${VERSION:-${VERSION_ID:-unknown}}")
        _pretty="${_os_info%%|*}"
        _id="${_os_info#*|}"; _id="${_id%%|*}"
        _version="${_os_info##*|}"
        unset _os_info

        if [[ -n "$_pretty" ]]; then
            # PRETTY_NAME already includes the version (e.g. "Ubuntu 24.04.4 LTS")
            echo "${RESET}OS Detect: $BOLD$GREEN$OS$RESET/$BOLD$GREEN$_pretty$RESET"
        else
            echo "${RESET}OS Detect: $BOLD$GREEN$OS$RESET/$BOLD$GREEN$_id$RESET Version $BOLD$GREEN$_version$RESET"
        fi
        unset _pretty _id _version
    else
        echo "${RESET}OS Detect: $BOLD$GREEN$OS$RESET"
    fi
else
    echo "$RESET == OS Detect:$BOLD$GREEN $OS$RESET == "
fi
