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
    echo " == Jvim Autorun == "
    export DOTFILESAUTO=0
fi
# } ===

#===============================================================================
# Detect OS {
#===============================================================================

if [[ -f $DOTFILES/scripts/detectOS ]]; then
    source $DOTFILES/scripts/detectOS
fi

# } ===

printf " == "

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
    printf "[Python Virtual Env Wrapper] "
else
    printf "[Python Virtual Env Wrapper NOT FOUND] "
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
        printf "[OSX Bash Completion] "
    else
        printf "[OSX Bash Completion NOT FOUND] "
    fi
fi
# }



#===============================================================================
# Bash Git-Prompt {
#===============================================================================
if [[ $SHELL == '/bin/bash' ]]; then
    if [[ -f $DOTFILES/shell/git-prompt.sh ]]; then
        source $DOTFILES/shell/git-prompt.sh

        export GIT_PS1_SHOWCOLORHINTS=1
        #PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\$ "'
        PROMPT_COMMAND='__git_ps1 "${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\\[\033[00m\]" "\\[\033[00m\]\$ "'
        printf "[Bash Git Prompt] "
    else
        printf "[Bash Git Prompt NOT FOUND] "
    fi
fi
# }

printf " == \n"
echo " == ready == "
