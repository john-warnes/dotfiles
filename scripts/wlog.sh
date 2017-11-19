#!/bin/bash -
#===============================================================================
#
#          FILE: watchlog.sh
#
#         USAGE: ./watchlog.sh
#
#        AUTHOR: John Warnes (jwarnes), johnwarnes@mail.weber.edu
#       CREATED: 09/06/17 15:28:48
#===============================================================================

# Use colors, but only if connected to a terminal, and that terminal
    # supports them.
    if which tput >/dev/null 2>&1; then
        ncolors=$(tput colors)
    fi
    if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
        RED="$(tput setaf 1)"
        GREEN="$(tput setaf 2)"
        YELLOW="$(tput setaf 3)"
        BLUE="$(tput setaf 4)"
        BOLD="$(tput bold)"
        RESET="$(tput sgr0)"
    else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        BOLD=""
        RESET=""
    fi

echo "$BOLD${RED}C${GREEN}O${YELLOW}L${BLUE}O${RED}R${GREEN}S$RESET$BOLD support$GREEN ON$RESET"

set -o nounset                              # Treat unset variables as an error

if [[ $# < 1 ]]; then
    echo "Usage $0 <Logfile>"
fi

if ! [[ -f $1 ]]; then
    echo "${RED}ERROR:$RESET Log file '$1' not found."
fi

QUITKEY=0
key=""

while [[ $QUITKEY == 0 ]]; do

    read -t 0 -n 1 key
    if [[ $key == 'q' ]]; then
        QUITKEY=1
    fi

    echo -n "$YELLOW"
    head -n 1 $1
    echo -n "$RESET"
    tail -n 0 -f $1 | head -n 10

done


