#!/bin/bash
#=================================================================
#  Revision  0104
#  Modified  Wednesday, 21 July 2021
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
    if [[ -f $DOTFILES/scripts/detectOS.sh ]]; then
        source $DOTFILES/scripts/detectOS.sh
    fi
}
# } ===

#===============================================================================
# Python Virtual Environments {
#===============================================================================
PythonVirtualEnvironments()
{
    if [[ -f $HOME/.local/bin/virtualenvwrapper.sh ]] || [[ -f /usr/local/bin/virtualenvwrapper.sh ]]; then

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
        export VIRTUALENVWRAPPER_PYTHON=`which python3`

        if [[ -f $HOME/.local/bin/virtualenvwrapper.sh ]]; then
            source $HOME/.local/bin/virtualenvwrapper.sh
        elif [[ -f /usr/local/bin/virtualenvwrapper.sh ]]; then
            source /usr/local/bin/virtualenvwrapper.sh
        fi
        printf "${RESET}${GREEN}Python Virt Wrapper$RESET|"
    else
        printf "${RESET}${YELLOW}!! Python Virt Wrapper !!$RESET "
    fi
}
#} ===


#===============================================================================
# Script Path {
#===============================================================================
ScriptsPath()
{
    if [[ -d $DOTFILES/scripts ]]; then
        export PATH="$PATH:$DOTFILES/scripts"
        printf "${RESET}${GREEN}Scripts Path$RESET|"
    else
        printf "${RESET}${YELLOW}!! Scripts Path !!$RESET "
    fi
}
# } ===


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
        if [[ -f $(brew --prefix)/etc/bash_completion ]]; then
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
checkvenv()
{
    if [[ ${VIRTUAL_ENV:-0} == 0 ]]; then
        echo ""
    else
        echo "(`basename \"$VIRTUAL_ENV\"`)\n"
    fi
}

BashGit-Prompt ()
{
    if [[ $SHELL == '/bin/bash' ]]; then
        if [[ -f $DOTFILES/shell/git-prompt.sh ]]; then
            source $DOTFILES/shell/git-prompt.sh

            export GIT_PS1_SHOWCOLORHINTS=1
            #PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\$ "' # orginal
            #PROMPT_COMMAND='__git_ps1 "${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\\[\033[00m\]" "\\[\033[00m\]\$ "' # just the git on line
            PROMPT_COMMAND='__git_ps1 "$(checkvenv)${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\\[\033[00m\]" "\\[\033[00m\]\$ "' # virtual env on pre line if using one

            printf "${RESET}${GREEN}Bash git-Prompt$RESET|"
        else
            printf "${RESET}${YELLOW}!! Bash git-Prompt !!$RESET|"
        fi
    fi
}
#} ===

#===============================================================================
# flutter bash completion {
#===============================================================================
FlutterBashCompletion () {
    # Currently is working in zsh and bash
    if [[ -f $DOTFILES/shell/flutter_bash_completion.sh ]]; then
        source $DOTFILES/shell/flutter_bash_completion.sh
        printf "${RESET}${GREEN}Flutter Bash Completion$RESET"
    else
        printf "${RESET}${YELLOW}!! Flutter Bash Completion !!$RESET"
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

    if [[ $@ > 0 ]]; then
        echo "autorun exec from: $1"
    fi

    # Might need to force it
    #HASRUN=0
    # this need more testing to see if detecting loaded or not

    if ! [[ $HASRUN ]]; then
        printf "$RESET[dotfiles reload: "
        BashGit-Prompt
        echo "]"
    else
        printf "["
        #PythonVirtualEnvironments

        ShellAliases
        PersonalAliases
        ScriptsPath

        #OSXBashCompletion
        BashGit-Prompt
        FlutterBashCompletion

        echo "]"
        echo "${RESET}DOTFILES${GREEN} Ready$RESET"
    fi

    # Set History to 200k lines, memory and file
    export HISTSIZE=200000
    export HISTFILESIZE=200000
}
#} ===
main "$@"     #remember to pass all command line args
