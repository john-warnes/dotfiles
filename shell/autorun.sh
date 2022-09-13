#!/bin/bash

# ============================================================================
# Revision  0155
# Modified  2022 July 15
# ============================================================================

# ============================================================================
# Setup colors in the shell
# ============================================================================
Colors() {
    if [[ -f $DOT_FILES/scripts/colors.sh ]]; then
        source $DOT_FILES/scripts/colors.sh
    fi
}
# } ===

# ============================================================================
# Check if this has already been run {
# ============================================================================
RunCheck() {
    if [[ $DOT_FILES_AUTO == 1 ]]; then
        #echo "$RESET${GREEN}[dot files Already Loaded]$RESET"
        echo 1
    else
        export DOT_FILES_AUTO=1
        echo 0
    fi
}
# } ===

# ============================================================================
# Detect OS {
# ============================================================================
DetectOS() {
    if [[ -f $DOT_FILES/scripts/detectOS.sh ]]; then
        source $DOT_FILES/scripts/detectOS.sh
    fi
}
# } ===

# ============================================================================
# Python Virtual Environments {
# ============================================================================
PythonVirtualEnvironments() {
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
        export VIRTUALENVWRAPPER_PYTHON=$(which python3)

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

# ============================================================================
# Script Path {
# ============================================================================
ScriptsPath() {
    if [[ -d $DOT_FILES/scripts ]]; then
        export PATH="$PATH:$DOT_FILES/scripts"
        printf "${RESET}${GREEN}Scripts Path$RESET|"
    else
        printf "${RESET}${YELLOW}!! Scripts Path !!$RESET "
    fi
}
# } ===

# ============================================================================
# Shell Aliases {
# ============================================================================
ShellAliases() {
    if [[ -f $DOT_FILES/shell/shell_aliases ]]; then
        source $DOT_FILES/shell/shell_aliases
    fi
}
# } ===

# ============================================================================
# Personal Aliases {
# ============================================================================
PersonalAliases() {
    if [[ -f $DOT_FILES/secure/personal_aliases ]]; then
        source $DOT_FILES/secure/personal_aliases
    fi
}
# } ===

# ============================================================================
# OSX Bash Completion {
# ============================================================================
BashCompletion() {

    # Linux
    if [[ $OS == 'LINUX' ]] && ( [[ $SHELL == '/bin/bash' ]] || [[ $SHELL == '/bin/ash' ]] ); then

        # enable programmable completion features (you don't need to enable
        # this, if it's already enabled in /etc/bash.bashrc and /etc/profile
        # sources /etc/bash.bashrc).
        if ! shopt -oq posix; then
            if [ -f /usr/share/bash-completion/bash_completion ]; then
                . /usr/share/bash-completion/bash_completion
                printf "${RESET}${GREEN}Bash Complete$RESET|"
            elif [ -f /etc/bash_completion ]; then
                . /etc/bash_completion
                printf "${RESET}${GREEN}Bash Complete$RESET|"
            else
                printf "${RESET}${YELLOW}!! Bash Completion !!$RESET "
            fi
        else
            printf "${RESET}${YELLOW}!! Bash Completion !!$RESET "
        fi
        return
    fi

    # OSX
    if [[ $OS == 'OSX' ]] && [[ $SHELL == '/bin/bash' ]]; then
        if [[ -f $(brew --prefix)/etc/bash_completion ]]; then
            source $(brew --prefix)/etc/bash_completion
            printf "${RESET}${GREEN}Bash Complete$RESET|"
        else
            printf "${RESET}${YELLOW}!! Bash Completion !!$RESET "
        fi
        return
    fi
}
#} ===

# ============================================================================
# Bash Git-Prompt {
# ============================================================================
checkvenv() {
    if [[ ${VIRTUAL_ENV:-0} == 0 ]]; then
        echo ""
    else
        echo "($(basename \"$VIRTUAL_ENV\"))\n"
    fi
}

BashGit-Prompt() {

    if [[ $SHELL == '/bin/bash' || $SHELL == '/bin/zsh' || $SHELL == '/bin/ash' ]]; then
    # ash = https://en.wikipedia.org/wiki/Almquist_shell

        if [[ -f $DOT_FILES/shell/git-prompt.sh ]]; then

            source $DOT_FILES/shell/git-prompt.sh

            # VSCODE Imbedded Shell
            if [ ! -z $VSCODE_SHELL_INTEGRATION ]; then
                export GIT_PS1_SHOWDIRTYSTATE=1
                PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " (\[\033[01;32m\]%s\[\033[00m\])")\$ '
                printf "${RESET}${GREEN}VsCode git-prompt$RESET|"
                builtin return
            fi

            # Bash
            if [[ $SHELL == '/bin/bash' || $SHELL == '/bin/ash' ]]; then
                export GIT_PS1_SHOWCOLORHINTS=1
                # PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\$ "' # original
                # PROMPT_COMMAND='__git_ps1 "${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\\[\033[00m\]" "\\[\033[00m\]\$ "' # just the git on line
                PROMPT_COMMAND='__git_ps1 "$(checkvenv)${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\\[\033[00m\]" "\\[\033[00m\]\$ "' # virtual env on pre line if using one
                printf "${RESET}${GREEN}Bash git-prompt$RESET|"
                builtin return
            fi

            # Zsh
            if [[ $SHELL == '/bin/zsh' ]]; then
                export GIT_PS1_SHOWCOLORHINTS=1
                precmd() {
                    __git_ps1 "%n" ":%~$ " "|%s"
                }
                printf "${RESET}${GREEN}Zsh git-prompt$RESET|"
                builtin return
            fi
            printf "${RESET}${YELLOW}!! Unknown shell: skip git-prompt !!$RESET|"
        else
            printf "${RESET}${YELLOW}!! Bash git-prompt !!$RESET|"
        fi
    fi
}
#} ===

# ============================================================================
# flutter completion {
# ============================================================================
FlutterBashCompletion() {
    # Currently works in both zsh and bash
    if [[ -f $DOT_FILES/shell/flutter_bash_completion.sh ]]; then
        source $DOT_FILES/shell/flutter_bash_completion.sh
        printf "${RESET}${GREEN}Flutter Completion$RESET"
    else
        printf "${RESET}${YELLOW}!! Flutter Completion !!$RESET"
    fi
}
#} ===

# ============================================================================
# main {
# ============================================================================
main() {
    Colors
    DetectOS

    HAS_RUN=$(RunCheck)

    if [[ $@ > 0 ]]; then
        echo "auto run exec from: $1"
    fi

    # Might need to force it
    #HAS_RUN=0
    # this need more testing to see if detecting loaded or not

    if ! [[ $HAS_RUN ]]; then
        printf "$RESET[dot files reload: "
        BashGit-Prompt
        echo "]"
    else
        printf "["
        #PythonVirtualEnvironments

        ShellAliases
        PersonalAliases
        ScriptsPath

        BashCompletion
        BashGit-Prompt
        FlutterBashCompletion

        echo "]"
        echo "${RESET}DOT_FILES${GREEN} Ready$RESET"
    fi

    # Set History to 200k lines, memory and file
    export HISTSIZE=200000
    export HISTFILESIZE=200000
}
#} ===
main "$@" #remember to pass all command line args
