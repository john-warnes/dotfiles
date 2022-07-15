#!/bin/bash -
#===============================================================================
#          FILE: CreateUserLinux.sh
#         USAGE: ./CreateUserLinux.sh
#        AUTHOR: John Warnes (), john@warnes.email
#===============================================================================

set -o nounset # Treat unset variables as an error

set +x #echo off
set +v #echo off

source 'colors.sh'

GROUP=$(groups | cut -d " " -f2- | sed 's/[ \t]+*/,/g' | sed 's/adm,//g' | sed 's/sudo,//g')
GROUP_SUDO=$(groups | cut -d " " -f2- | sed 's/[ \t]+*/,/g')
DEFAULT_PASS="$(tr -cd '[:alnum:]' </dev/urandom | fold -w10 | head -n1)"

# echo "$# : $@"   #debug show args

if [[ $# == 1 ]]; then

    NAME=$1
    if [[ $NAME == $USER ]]; then
        echo "$RED${BOLD}Error!$RESET$BOLD Attempted to Create $GREEN$NAME$RESET$BOLD with account $GREEN$USER$RESET"
        echo "${BOLD}Try running$BLUE whoami$RESET"
        exit -1
    fi

    printf "$BLUE${BOLD}Adding user$GREEN %s$RESET\n" "$NAME"
    echo "${BOLD}sudo useradd -m -s $SHELL -G $GROUP_SUDO $NAME$RESET"
    sudo useradd -m -s $SHELL -G $GROUP_SUDO $NAME >/dev/null
    echo "${BOLD}echo -e \"${DEFAULT_PASS}\n${DEFAULT_PASS}\" | (sudo passwd -q $NAME) > /dev/null$RESET"
    echo -e "${DEFAULT_PASS}\n${DEFAULT_PASS}" | (sudo passwd $NAME)
    if [[ $NAME == *test* ]]; then
        echo "${BOLD}sudo passwd -q -u $NAME$RESET"
        sudo passwd -u $NAME
    else
        echo "${BOLD}sudo passwd -q -e $NAME$RESET"
        sudo passwd -e $NAME
    fi
    echo "############################"
    echo " Username: $NAME"
    echo " Password: $DEFAULT_PASS"
    echo "###########################"

elif [[ -s "./CreateUsersLinux.list" ]]; then
    FILE="./CreateUsersLinux.list"

    echo "$BOLD${BLUE}ListFile:$GREEN $FILE$RESET"

    file=${1--} # POSIX-compliant; ${1:--} can be used either.
    while IFS= read -r NAME; do

        if [[ $NAME == $USER ]]; then
            echo "$YELLOW${BOLD}Warring!$RESET$BOLD Attempted to Create $GREEN$NAME$RESET$BOLD with account $GREEN$USER$YELLOW Skipping$RESET"
            continue
        fi

        printf "${BOLD}${BLUE}Adding user$GREEN %s$RESET\n" "$NAME"
        echo "${BOLD}sudo useradd -m -s $SHELL -G $GROUP $NAME$RESET"
        sudo useradd -m -s $SHELL -G $GROUP $NAME >/dev/null
        echo "${BOLD}echo -e \"${DEFAULT_PASS}\n${DEFAULT_PASS}\" | (sudo passwd $NAME) > /dev/null $RESET"
        echo -e "${DEFAULT_PASS}\n${DEFAULT_PASS}" | (sudo passwd $NAME)
        echo "${BOLD}sudo passwd -q -e $NAME$RESET"
        sudo passwd -e $NAME

    done <$FILE
fi

echo "${BOLD}${BLUE}-done$RESET"
