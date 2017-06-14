#!/bin/bash

# IDs help ---> https://github.com/zyga/os-release-zoo
SUPPORTEDDISTROS="ubuntu, linuxmint, debian, elementary OS, neon, peppermint, Zorin OS"

source /etc/os-release    #Load OS VARS
case "$OSTYPE" in
    solaris*) OS="SOLARIS" ;;
    darwin*)  OS="OSX" ;;
    linux*)   OS="LINUX" ;;
    bsd*)     OS="BSD" ;;
    msys*)    OS="WINDOWS" ;;
    *)        OS="unknown: $OSTYPE" ;;
esac

if [[  $OS == 'LINUX' ]]; then
    $DISTRO == $ID ]];
fi

