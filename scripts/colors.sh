#!/bin/bash -
#=================================================================
#          FILE  colors.sh
#         USAGE  ./colors.sh
#
#        AUTHOR  John Warnes (), johnwarnes@mail.weber.edu
#      Revision  016
#      Modified  Friday, 23 March 2018
#=================================================================

set -o nounset # Treat unset variables as an error

# Use colors, but only if connected to a terminal, and that terminal
# supports them.
if (($CLICOLOR == 1)); then
    ncolors=16
else
    if which tput >/dev/null 2>&1; then
        ncolors=$(tput colors)
    fi
fi

if [ -t 1 ] && [ -n "$ncolors" ] && (( $ncolors >= 8 )); then
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

if [[ $# > 0 ]]; then
    echo "$BOLD${RED}C${GREEN}O${YELLOW}L${BLUE}O${RED}R${GREEN}S$RESET$BOLD support$GREEN ON$RESET"
fi

set +o nounset # Do Not treat unset variables as an error
