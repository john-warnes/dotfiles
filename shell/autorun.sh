#!/bin/bash -
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

set -o nounset                              # Treat unset variables as an error

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
    set +o nounset                              # Ignore unset variables
    source /usr/local/bin/virtualenvwrapper.sh
    set -o nounset                              # Treat unset variables as an error
}
VirtualEnvWrapper

RunShellAliases()
{
    # Set Dir for env configs
    if [[ -e $DOTIFLES/shell/shellaliases ]]; then
        set +o nounset                              # Ignore unset variables
        source $DOTFILES/shell/shellaliases         # Source shellAliases
        set -o nounset                              # Treat unset variables as an error
    fi
}
RunShellAliases


PersonalAliases()
{
    # Set Dir for env configs
    if [[ -e $DOTFILES/secure/personal.aliases.sh ]]; then
        set +o nounset                              # Ignore unset variables
        source $DOTFILES/secure/personal.aliases.sh # Source shellAliases
        set -o nounset                              # Treat unset variables as an error
    fi
}
ShellAliases

