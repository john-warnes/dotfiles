#!/usr/bin/env bash

# =rev=======================================================================
#          File: autorun.sh
#        Author: John Warnes, johnw@gurutechnologies.net
#       Created: 08/30/2022 03:09:00 PM
#      Revision: 0171
#      Modified: Wednesday, 4 February 2026
#       Version: 2.0.0
# ===========================================================================

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
# SSH Terminal Configuration {
# ============================================================================
SSHConfiguration() {
    # Check if we're in an SSH session
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
        # Ensure proper TERM for colors over SSH
        case "$TERM" in
            xterm|xterm-color|xterm-256color)
                export TERM=xterm-256color
                ;;
            screen|screen-256color)
                export TERM=screen-256color
                ;;
            tmux|tmux-256color)
                export TERM=tmux-256color
                ;;
        esac

        # Enable true color support if terminal supports it
        if [ -z "$COLORTERM" ]; then
            export COLORTERM=truecolor
        fi

        # Set locale for proper character encoding
        export LC_ALL=en_US.UTF-8
        export LANG=en_US.UTF-8

        printf "${RESET}${GREEN}SSH Session$RESET|"
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
        export WORKON_HOME=$HOME/.virtualenvs

        # Set Dir for development director
        if ! [[ -d $HOME/dev ]]; then
            mkdir $HOME/dev
        fi
        export PROJECT_HOME=$HOME/dev

        #what python to use
        export VIRTUALENVWRAPPER_PYTHON="$(which python3)"

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
# Set Cursor {
# ============================================================================
SetCursor() {
    # Skip cursor changes in VSCode integrated terminal
    if [ -n "$VSCODE_SHELL_INTEGRATION" ] || [ "$TERM_PROGRAM" = "vscode" ]; then
        return
    fi
    if [[ -f $DOT_FILES/shell/set_cursor.sh ]]; then
        source $DOT_FILES/shell/set_cursor.sh
        printf "${RESET}${GREEN}SetCursor$RESET|"
    fi
}
# } ===

# ============================================================================
# OSX Bash Completion {
# ============================================================================
BashCompletion() {

    # Linux
    if [[ $OS == 'LINUX' ]] && ([[ $SHELL == '/bin/bash' ]] || [[ $SHELL == '/bin/ash' ]]); then

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
        if [[ -f "$(brew --prefix)/etc/bash_completion" ]]; then
            source "$(brew --prefix)/etc/bash_completion"
            printf "${RESET}${GREEN}Bash Complete$RESET|"
        else
            printf "${RESET}${YELLOW}!! Bash Completion !!$RESET "
        fi
        return
    fi
}
#} ===

# ============================================================================
# Bash Git Prompt {
# ============================================================================
checkvenv() {
    if [[ ${VIRTUAL_ENV:-0} == 0 ]]; then
        echo ""
    else
        echo "($(basename \"$VIRTUAL_ENV\"))\n"
    fi
}

BashGitPrompt() {

    if [[ $SHELL == '/bin/bash' || $SHELL == '/bin/zsh' || $SHELL == '/bin/ash' ]]; then
        # ash = https://en.wikipedia.org/wiki/Almquist_shell

        if [[ -f $DOT_FILES/shell/git-prompt.sh ]]; then

            source $DOT_FILES/shell/git-prompt.sh

            # VSCODE Integrated Terminal
            if [ -n "$VSCODE_SHELL_INTEGRATION" ]; then
                export GIT_PS1_SHOWDIRTYSTATE=1
                export GIT_PS1_SHOWUNTRACKEDFILES=1
                export GIT_PS1_SHOWSTASHSTATE=1

                # Simpler prompt for VSCode - it handles decorations itself
                # Use PS1 instead of PROMPT_COMMAND to avoid conflicts with VSCode's shell integration
                PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " (\[\033[01;32m\]%s\[\033[00m\])")\$ '

                # Disable problematic features in VSCode
                unset PROMPT_COMMAND  # VSCode manages its own prompt command

                printf "${RESET}${GREEN}VSCode git-prompt$RESET|"
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
# VSCode Terminal Optimizations {
# ============================================================================
VSCodeOptimizations() {
    if [ -n "$VSCODE_SHELL_INTEGRATION" ] || [ "$TERM_PROGRAM" = "vscode" ]; then
        # Disable features that conflict with VSCode's shell integration

        # VSCode handles command execution tracking, so we simplify output
        export VSCODE_TERMINAL=1

        # Ensure VSCode's shell integration script is sourced if available
        # VSCode typically injects this automatically, but we can check
        if [ -n "$VSCODE_INJECTION" ] && [ "$VSCODE_INJECTION" = "1" ]; then
            # VSCode's shell integration is active
            :
        fi

        # Optimize history for VSCode terminal
        # VSCode can track commands across sessions, so we ensure history is immediate
        if [[ $SHELL == '/bin/bash' ]]; then
            shopt -s histappend
            PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a"
        fi

        printf "${RESET}${GREEN}VSCode Terminal$RESET|"
    fi
}
# } ===

# ============================================================================
# main {
# ============================================================================
main() {
    # Check if DOT_FILES is set and valid
    if [[ -z "$DOT_FILES" ]]; then
        echo "ERROR: DOT_FILES environment variable is not set!" >&2
        echo "Please set DOT_FILES to your dotfiles directory path." >&2
        echo "Example: export DOT_FILES=~/dotfiles" >&2
        return 1
    fi

    if [[ ! -d "$DOT_FILES" ]]; then
        echo "ERROR: DOT_FILES directory does not exist: $DOT_FILES" >&2
        return 1
    fi

    Colors
    DetectOS

    HAS_RUN=$(RunCheck)

    if [[ $# -gt 0 ]]; then
        echo "auto run exec from: $1"
    fi

    # Might need to force it
    #HAS_RUN=0
    # this need more testing to see if detecting loaded or not

    if [[ $HAS_RUN -eq 1 ]]; then
        printf "$RESET[dot files reload: "
        BashGitPrompt
        echo "]"
    else
        printf "["

        SSHConfiguration
        VSCodeOptimizations

        #PythonVirtualEnvironments

        # Colors already loaded at top of file
        if [[ -f $DOT_FILES/scripts/colors.sh ]]; then
            printf "${RESET}${GREEN}Colors$RESET|"
        fi
        SetCursor
        ShellAliases
        PersonalAliases
        ScriptsPath

        BashCompletion
        BashGitPrompt
        FlutterBashCompletion

        echo "]"

        echo "${RESET}DOT_FILES${GREEN} Ready$RESET"
    fi

    # Set history to 200k lines, memory and file
    if [[ $SHELL == '/bin/bash' || $SHELL == '/bin/ash' ]]; then
        export HISTSIZE=200000
        export HISTFILESIZE=200000

        # Enable history appending instead of overwriting
        shopt -s histappend

        # Tmux history sharing: append and reload history after each command
        if [ -n "$TMUX" ]; then
            # In tmux: append history immediately and reload from all sessions
            # This allows real-time history sharing across tmux panes
            if [ -z "$VSCODE_TERMINAL" ]; then
                # Don't override VSCode's PROMPT_COMMAND if it exists
                export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -n"
            fi
            printf "${RESET}${GREEN}Tmux history sharing enabled$RESET\n"
        else
            # Not in tmux: just append history on exit
            shopt -s histappend
        fi

    elif [[ $SHELL == '/bin/zsh' ]]; then
        export HISTSIZE=200000
        export SAVEHIST=200000
        export HISTFILE="$HOME/.zsh_history"

        # Zsh history sharing in tmux
        if [ -n "$TMUX" ]; then
            setopt SHARE_HISTORY        # Share history across all sessions
            setopt INC_APPEND_HISTORY   # Append immediately
            setopt HIST_IGNORE_DUPS     # Don't record duplicates
            printf "${RESET}${GREEN}Tmux history sharing enabled$RESET\n"
        fi
    fi
}
#} ===
main "$@" #remember to pass all command line args
