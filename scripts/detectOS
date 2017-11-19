#!/bin/bash

case "$OSTYPE" in
    solaris*) export OS="SOLARIS";;
    darwin*)  export OS="OSX";;
    linux*)   export OS="LINUX";;
    bsd*)     export OS="BSD";;
    cygwin*)  export OS="BABUN";;
    msys*)    export OS="WINDOWS";;
    *)        export OS="unknown: $OSTYPE";;
esac

if [[ $OS != "LINUX" ]]; then
    echo "$RESET == OS Detect:$BOLD$GREEN $OS$RESET == "
else
    # IDs help ---> https://github.com/zyga/os-release-zoo
    source /etc/os-release    #Load OS VARS
    if [[ $OS == "LINUX" ]]; then
        DISTRO="$ID"
        export OS
        export DISTRO

        if [[ -n $PRETTY_NAME ]]; then
            echo "${RESET}OS Detect: $BOLD$GREEN$OS$RESET/$BOLD$GREEN$PRETTY_NAME$RESET Version $BOLD$GREEN$VERSION$RESET"
        else
            echo "${RESET}OS Detect: $BOLD$GREEN$OS$RESET/$BOLD$GREEN$DISTRO$RESET Version $BOLD$GREEN$VERSION$RESET"
        fi
    fi
fi

