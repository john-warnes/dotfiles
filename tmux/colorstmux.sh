#!/bin/bash -
#===============================================================================
#
#          FILE: tmuxcolor.sh
#
#         USAGE: ./tmuxcolor.sh 
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: John Warnes (), johnwarnes@mail.weber.edu
#  ORGANIZATION: WSU
#       CREATED: 06/02/2017 02:03:01 AM
#      REVISION:  ---
#===============================================================================

if [ -z $1 ]; then
    BREAK=4
else
    BREAK=$1
fi
for i in {0..255} ; do
    printf "\x1b[38;5;${i}mcolour${i} \t"
    if [ $(( i % $BREAK )) -eq $(($BREAK-1)) ] ; then
        printf "\n"
    fi
done
