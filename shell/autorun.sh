#!/bin/bash
#=================================================================
#  Revision  032
#  Modified  Sunday, 12 November 2017
#=================================================================


#===============================================================================
# Check if this has already been run {
#===============================================================================
Colors()
{
    if [[ -f $DOTFILES/scripts/colors.sh ]]; then
        source $DOTFILES/scripts/colors.sh
    fi
}
# } ===


#===============================================================================
# Check if this has already been run {
#===============================================================================
RunCheck()
{
    if [[ $DOTFILESAUTO == 1 ]]; then
        #echo "$RESET${GREEN}[dotfiles Already Loaded]$RESET"
        echo 1
    else
        export DOTFILESAUTO=1
        echo 0
    fi
}
# } ===


#===============================================================================
# Detect OS {
#===============================================================================
DetectOS()
{
    if [[ -f $DOTFILES/scripts/detectOS ]]; then
        source $DOTFILES/scripts/detectOS
    fi
}
# } ===


#===============================================================================
# Python Virtual Environments {
#===============================================================================
PythonVirtualEnvironments()
{
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
}
#} ===


#===============================================================================
# Shell Aliases {
#===============================================================================
ShellAliases()
{
    if [[ -f $DOTFILES/shell/shell_aliases ]]; then
        source $DOTFILES/shell/shell_aliases
    fi
}
# } ===


#===============================================================================
# Personal Aliases {
#===============================================================================
PersonalAliases ()
{
    if [[ -f $DOTFILES/secure/personal_aliases ]]; then
        source $DOTFILES/secure/personal_aliases
    fi
}
# } ===


#===============================================================================
# OSX Bash Completion {
#===============================================================================
OSXBashCompletion ()
{
    if [[ $OS == 'OSX' ]] && [[ $SHELL == '/bin/bash' ]]; then
        if [ -f $(brew --prefix)/etc/bash_completion ]; then
            source $(brew --prefix)/etc/bash_completion
            printf "${RESET}${GREEN}OSX Bash Complete$RESET|"
        else
            printf "${RESET}${YELLOW}!! OSX Bash Completion !!$RESEET "
        fi
    fi
}
#} ===


#===============================================================================
# Bash Git-Prompt {
#===============================================================================
BashGit-Prompt ()
{
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
}
#} ===


#===============================================================================
# main {
#===============================================================================
main()
{
    Colors
    DetectOS

    HASRUN=$(RunCheck)

    if [[ $HASRUN ]]; then
        printf "$RESET[dotfiles reload: "
        BashGit-Prompt
        echo "]"
    else
        printf "["
        PythonVirtualEnvironments

        ShellAliases
        PersonalAliases

        OSXBashCompletion
        BashGit-Prompt

        echo "]"
        echo "${RESET}DOTFILES${GREEN} Ready$RESET"
    fi

}
#} ===
main "$@"     #remember to pass all command line args
