#!/bin/bash -
#===============================================================================
#
#          FILE: colors.sh
#
#         USAGE: ./colors.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: John Warnes (), johnwarnes@mail.weber.edu
#  ORGANIZATION: WSU
#       CREATED: 06/01/2017 04:43:14 PM
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

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


