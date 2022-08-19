#!/bin/bash -
#=================================================================
#          FILE  colors.sh
#         USAGE  ./colors.sh
#
#        AUTHOR  John Warnes (), john@warnes.email
#      Revision  020
#      Modified  Friday, 19 March 2022
#=================================================================

# set -o nounset # Treat unset variables as an error

# Use colors
# If connected to a terminal [ -t 1 ] and the CLICOLOR env set set
if [ -t 1 ] && (($CLICOLOR == 1)); then

    # This function evaluates the echo to turn the ESC sequence into a true byte value
    esc() {
        local ESC="\x1B" # "\e"
        eval 'echo -e "$ESC$1"'
    }

    # Reset
    RESET=$(esc '[0m')  # Reset all modes and colors

    # Foreground
    BLACK=$(esc '[30m')
    RED=$(esc '[31m')
    GREEN=$(esc '[32m')
    YELLOW=$(esc '[33m')
    BLUE=$(esc '[34m')
    MAGENTA=$(esc '[35m')
    CYAN=$(esc '[36m')
    WHITE=$(esc '[37m')
    DEFAULT=$(esc '[39m')

    # Background
    BACK_BLACK=$(esc '[40m')
    BACK_RED=$(esc '[41m')
    BACK_GREEN=$(esc '[42m')
    BACK_YELLOW=$(esc '[43m')
    BACK_BLUE=$(esc '[44m')
    BACK_MAGENTA=$(esc '[45m')
    BACK_CYAN=$(esc '[46m')
    BACK_WHITE=$(esc '[47m')
    BACK_DEFAULT=$(esc '[49m')

    # Modes
    BOLD=$(esc '[1m')
    NORMAL=$(esc '[22m')
    DIM=$(esc '[2m')

    # Advanced Modes
    ITALIC=$(esc '[3m')
    UNDERLINE=$(esc '[4m')
    BLINK=$(esc '[5m')
    INVERSE=$(esc '[7m')
    HIDDEN=$(esc '[8m')
    STRIKETHROUGH=$(esc '[9m')

    # Reset Modes (Only upsets the mode)
    BOLD_RESET=$(esc '[22m')
    DIM_RESET=$(esc '[22m')
    ITALIC_RESET=$(esc '[23m')
    UNDERLINE_RESET=$(esc '[24m')
    BLINK_RESET=$(esc '[25m')
    INVERSE_RESET=$(esc '[27m')
    HIDDEN_RESET=$(esc '[28m')
    STRIKETHROUGH_RESET=$(esc '[29m')
else
    unset RESET

    # Foreground
    unset BLACK
    unset RED
    unset GREEN
    unset YELLOW
    unset BLUE
    unset MAGENTA
    unset CYAN
    unset WHITE
    unset DEFAULT

    # Background
    unset BACK_BLACK
    unset BACK_RED
    unset BACK_GREEN
    unset BACK_YELLOW
    unset BACK_BLUE
    unset BACK_MAGENTA
    unset BACK_CYAN
    unset BACK_WHITE
    unset BACK_DEFAULT

    # Modes
    unset BOLD
    unset NORMAL
    unset DIM

    # Advanced Modes
    unset ITALIC
    unset UNDERLINE
    unset BLINK
    unset INVERSE
    unset HIDDEN
    unset STRIKETHROUGH

    # Reset Modes (Only upsets the mode)
    unset BOLD_RESET
    unset DIM_RESET
    unset ITALIC_RESET
    unset UNDERLINE_RESET
    unset BLINK_RESET
    unset INVERSE_RESET
    unset HIDDEN_RESET
    unset STRIKETHROUGH_RESET
fi

if [[ $# > 0 ]]; then
    echo "$BOLD${RED}C${GREEN}O${YELLOW}L${BLUE}O${RED}R${GREEN}S$RESET$BOLD support$GREEN ON$RESET"
fi

set +o nounset # Do Not treat unset variables as an error
