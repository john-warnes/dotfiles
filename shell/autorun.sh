#!/usr/bin/env bash

# =rev=======================================================================
#          File: autorun.sh
#        Author: John Warnes, johnw@gurutechnologies.net
#       Created: 08/30/2022 03:09:00 PM
#      Revision: 0172
#      Modified: Friday, 20 March 2026
#       Version: 2.0.0
# ===========================================================================

# ============================================================================
# Setup colors in the shell
# ============================================================================
Colors() {
    if [[ -f $DOT_FILES/scripts/colors.sh ]]; then
        source "$DOT_FILES/scripts/colors.sh"
    fi
}
# } ===

# ============================================================================
# Check if this has already been run {
# ============================================================================
RunCheck() {
    if [[ $DOT_FILES_AUTO == 1 ]]; then
        echo 1
    else
        echo 0
    fi
}
# } ===

# ============================================================================
# Detect OS {
# ============================================================================
DetectOS() {
    if [[ -f $DOT_FILES/scripts/detectOS.sh ]]; then
        source "$DOT_FILES/scripts/detectOS.sh"
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
        source "$DOT_FILES/shell/shell_aliases"
    fi
}
# } ===

# ============================================================================
# Personal Aliases {
# ============================================================================
PersonalAliases() {
    if [[ -f $DOT_FILES/secure/personal_aliases ]]; then
        source "$DOT_FILES/secure/personal_aliases"
    fi
}
# } ===

# ============================================================================
# Set Cursor {
# ============================================================================
SetCursor() {
    if [[ -f $DOT_FILES/shell/set_cursor.sh ]]; then
        source "$DOT_FILES/shell/set_cursor.sh"
        printf "${RESET}${GREEN}SetCursor$RESET|"
    fi
}
# } ===

# ============================================================================
# Bash Completion (Linux + OSX) {
# ============================================================================
BashCompletion() {

    # Linux
    if [[ $OS == 'LINUX' ]] && ([[ $SHELL == */bash ]] || [[ $SHELL == */ash ]]); then

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
    if [[ $OS == 'OSX' ]] && [[ $SHELL == */bash ]]; then
        if command -v brew &>/dev/null && [[ -f "$(brew --prefix)/etc/bash_completion" ]]; then
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
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "($(basename "$VIRTUAL_ENV")) "
    fi
}

shortpwd() {
    local pwd_str
    if [[ "$PWD" == "$HOME" ]]; then
        pwd_str="~"
    elif [[ "$PWD" == "$HOME/"* ]]; then
        pwd_str="~${PWD#"$HOME"}"
    else
        pwd_str="$PWD"
    fi

    local max_len=30
    if [[ ${#pwd_str} -le $max_len ]]; then
        printf '%s' "$pwd_str"
        return
    fi
    # Preserve leading ~ so home paths show as ~.../tail instead of .../tail
    local prefix=""
    local trimmed="$pwd_str"
    if [[ "$trimmed" == '~/'* ]]; then
        prefix="~"
        trimmed="${trimmed#\~}"  # e.g. /a/b/c/d
    fi
    while [[ ${#trimmed} -gt $max_len ]]; do
        local next="${trimmed#*/}"
        [[ "$next" == "$trimmed" ]] && break
        trimmed="$next"
    done
    printf $'\001\033[90m\002%s...\001\033[01;34m\002/%s' "$prefix" "$trimmed"
}

GitPrompt() {

    if [[ $SHELL == */bash || $SHELL == */zsh || $SHELL == */ash ]]; then
        # ash = https://en.wikipedia.org/wiki/Almquist_shell

        if [[ -f /usr/lib/git-core/git-sh-prompt ]]; then
            source /usr/lib/git-core/git-sh-prompt
        elif [[ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]]; then
            source /usr/share/git-core/contrib/completion/git-prompt.sh
        else
            printf "${RESET}${YELLOW}!! git-prompt not found !!$RESET|"
            return
        fi

        # Bash
        if [[ $SHELL == */bash || $SHELL == */ash ]]; then
            export GIT_PS1_SHOWCOLORHINTS=1
            PROMPT_COMMAND='__git_ps1 "$(checkvenv)${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]$(shortpwd)\\[\033[00m\]" "\\[\033[00m\]\$ "' # virtual env on pre line if using one
            printf "${RESET}${GREEN}Git Prompt$RESET|"
            builtin return
        fi

        # Zsh
        if [[ $SHELL == */zsh ]]; then
            precmd() {
                __git_ps1 "%n" ":%~$ " "|%s"
            }
            printf "${RESET}${GREEN}Git Prompt$RESET|"
            builtin return
        fi
        printf "${RESET}${YELLOW}!! Unknown shell: skip git-prompt !!$RESET|"
    fi
}
#} ===

# ============================================================================
# flutter completion {
# ============================================================================
FlutterBashCompletion() {
    if command -v flutter &>/dev/null; then
        source <(flutter bash-completion 2>/dev/null)
        printf "${RESET}${GREEN}Flutter Completion$RESET|"
    else
        printf "${RESET}${YELLOW}!! Flutter Completion !!$RESET|"
    fi
}
#} ===

# ============================================================================
# History Configuration {
# ============================================================================
HistoryConfig() {
    if [[ $SHELL == */bash || $SHELL == */ash ]]; then
        export HISTSIZE=200000
        export HISTFILESIZE=1000000

        # Enable history appending instead of overwriting
        shopt -s histappend

        # Append new commands to history file on every prompt (no cross-session sync)
        PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

    elif [[ $SHELL == */zsh ]]; then
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
# } ===

# ============================================================================
# VSCode Terminal Optimizations {
# ============================================================================
VSCodeOptimizations() {
    if [[ "$TERM_PROGRAM" = "vscode" ]]; then
        export VSCODE_TERMINAL=1

        # Manual Fallback for Shell Integration
        # We check for the VSCODE_INJECTION var or the specific function
        if [[ -z "$VSCODE_INJECTION" ]] && ! declare -f __vsc_prompt_command > /dev/null; then
            # Use 'command -v code' to ensure the binary exists before calling it
            if command -v code >/dev/null 2>&1; then
                # Detect shell name for integration script lookup
                local shell_name
                shell_name=$(basename "$SHELL")
                local SCRIPT_PATH
                SCRIPT_PATH=$(code --locate-shell-integration-path "$shell_name" 2>/dev/null)
                if [[ -f "$SCRIPT_PATH" ]]; then
                    . "$SCRIPT_PATH"
                fi
            fi
        fi

        printf " ${RESET}${GREEN}|VSCode Terminal$RESET"
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
    export DOT_FILES_AUTO=1

    if [[ $# -gt 0 ]]; then
        echo "auto run exec from: $1"
    fi

    if [[ $HAS_RUN -eq 1 ]]; then
        printf "%s[autorun skipped: already loaded]\n" "$RESET"
        return 0
    else
        printf "["

        SSHConfiguration

        # Colors already loaded at top of file
        if [[ -f $DOT_FILES/scripts/colors.sh ]]; then
            printf "${RESET}${GREEN}Colors$RESET|"
        fi
        ShellAliases
        PersonalAliases
        ScriptsPath

        if [[ -z "$VSCODE_SHELL_INTEGRATION" && "$TERM_PROGRAM" != "vscode" ]]; then
            # SetCursor
            BashCompletion
            FlutterBashCompletion
            GitPrompt
        fi

        HistoryConfig
        VSCodeOptimizations

        echo "]"

        echo "${RESET}DOT_FILES${GREEN} Ready$RESET"
    fi

}
#} ===
main "$@" #remember to pass all command line args
