#!/bin/bash

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
        source /etc/os-release # Load OS VARS
        OS_ID="$ID"
        export OS
        export OS_ID

        if [[ -n $PRETTY_NAME ]]; then
            echo "${RESET}OS Detect: $BOLD$GREEN$OS$RESET/$BOLD$GREEN$PRETTY_NAME$RESET Version $BOLD$GREEN$VERSION$RESET"
        else
            echo "${RESET}OS Detect: $BOLD$GREEN$OS$RESET/$BOLD$GREEN$OS_ID$RESET Version $BOLD$GREEN$VERSION$RESET"
        fi
    else
        echo "${RESET}OS Detect: $BOLD$GREEN$OS$RESET"
    fi
else
    echo "$RESET == OS Detect:$BOLD$GREEN $OS$RESET == "
fi
