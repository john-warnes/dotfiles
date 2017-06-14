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


#===============================================================================
# Check if this has already been run {
#===============================================================================
if [[ $DOTFILESAUTO == 1 ]]; then
    echo " == Jvim Active == "
    return 0
else
    echo " == Jvim Autorun Starting == "
    export DOTFILESAUTO=1
fi
# } ===


#===============================================================================
# Python Virtual Environments {
#===============================================================================

if [[ -f /usr/local/bin/virtualenvwrapper.sh ]]; then

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

else
    echo " == Python Virtual Env Wrapper NOT FOUND == "
    echo "    /usr/local/bin/virtualenvwrapper.sh     "
fi
# } ===


#===============================================================================
# Shell Aliases {
#===============================================================================
if [[ -f $DOTFILES/shell/shell_aliases ]]; then
    source $DOTFILES/shell/shell_aliases
fi
# }


#===============================================================================
# Personal Aliases {
#===============================================================================
if [[ -f $DOTFILES/secure/personal_aliases ]]; then
    source $DOTFILES/secure/personal_aliases
fi
# }


#===============================================================================
# OSX Bash Completion {
#===============================================================================
if [[ $OS == 'OSX' ]] && [[ $SHELL == '/bin/bash' ]]; then
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
        source $(brew --prefix)/etc/bash_completion
        echo " == OSX Bash Completion Loaded == "
    else
        echo " == OSX Bash Completion NOT FOUND == "
    fi
fi
# }


echo " == Jvim Autorun Completed and Active == "
