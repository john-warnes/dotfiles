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
    #echo "$RESET${GREEN}[dotfiles Already Loaded]$RESET"
    return 0
else

if [[ -f $DOTFILES/scripts/colors.sh ]]; then
    source $DOTFILES/scripts/colors.sh
fi
    export DOTFILESAUTO=1
fi
# } ===

#===============================================================================
# Detect OS {
#===============================================================================

if [[ -f $DOTFILES/scripts/detectOS ]]; then
    source $DOTFILES/scripts/detectOS
fi

# } ===

printf "["

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
    printf "${RESET}${GREEN}Python Virt Wrapper,$RESET|"
else
    printf "${RESET}${YELLOW}!! Python Virt Wrapper !!$RESET "
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
        printf "${RESET}${GREEN}OSX Bash Complete$RESET|"
    else
        printf "${RESET}${YELLOW}!! OSX Bash Completion !!$RESEET "
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
        printf "${RESET}${GREEN}Bash git-Prompt$RESET"
    else
        printf "${RESET}${YELLOW}!! Bash git-Prompt !!$RESET"
    fi
fi
# }

echo "]"
echo "${RESET}DOTFILES${GREEN} Ready$RESET"
