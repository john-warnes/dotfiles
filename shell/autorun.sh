#!/bin/bash
#===============================================================================
#
#          FILE: autorun.sh
#
#         USAGE: ./autorun.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: John Warnes (jwarnes), johnwarnes@mail.weber.edu
#  ORGANIZATION: WSU
#       CREATED: 06/06/2017 04:35:35 PM
#      REVISION:  ---
#===============================================================================
set +o nounset #DO NOT MOVE LEAVE AS FIRST LINE

VirtualEnvWrapper()
{
    # Set Dir for env configs
    if ! [[ -d $HOME/.virtualenvs ]]; then
        mkdir $HOME/.virtualenvs
    fi
    export WORKON_HOME=$HOME/.virtualenv

    # Set Dir for development director
    if ! [[ -d $HOME/dev ]]; then
        mkdir $HOME/dev
    fi
    export PROJECT_HOME=$HOME/dev

    #what python to use
    export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
    source /usr/local/bin/virtualenvwrapper.sh
}
VirtualEnvWrapper

set +o nounset   #DO NOT MOVE LEAVE AS LAST LINE - Can add anytihng above if needed
