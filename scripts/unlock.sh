#!/bin/bash -
#===============================================================================
#
#          FILE: unlock.sh
#
#         USAGE: ./unlock.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: John Warnes (jwarnes), johnwarnes@mail.weber.edu
#  ORGANIZATION: WSU
#       CREATED: 06/06/2017 12:39:00 AM
#      REVISION:  ---
#===============================================================================

SECURE=$DOTFILES/secure
SCRIPTS=$DOTFILES/scripts

if [[ -f "$SCRIPTS/colors.sh" ]]; then
    source $SCRIPTS/colors.sh
fi

if ! [[ -d $SECURE ]]; then
    echo "$BOLD${RED}Error:$RESET$BOLD No secure directory detected: run './Dotfiles --decrypt' $RESET"
    exit 0
else
    (cd $SECURE && git reset --hard)
    (cd $SECURE && git pull --all)
fi



if ! [[ -f $SECURE/secure.tar.xz.gpg ]]; then
    echo "$BOLD${RED}Error:$RESET$BOLD Nothing to unlock as no secure file found$RESET"
    exit 0
fi

if [[ -f "$SECURE/secure.tar.xz" ]]; then
    echo "$BOLD${YELLOW}Note:$RESET$BOLD Shredding old tar.xz file$RESET"
    (exec shred -n 9 -uzf "$SECURE/secure.tar.xz")
fi

echo "$BOLD${BLUE}Unencrypting$RESET$BOLD tar.xz$RESET"
if [[ $# == 1 ]]; then
    # (cd "$SECURE" && exec gpg --passphrase-file <(echo $1) --yes --batch --output secure.tar.xz secure.tar.xz.gpg)
    (cd $SECURE && exec gpg --passphrase-file <(echo $1) secure.tar.xz.gpg)
else
    (cd $SECURE && exec gpg secure.tar.xz.gpg)
fi

echo "$BOLD${BLUE}Decompressing tar.zx to files$RESET"
(cd $SECURE && exec tar -xf secure.tar.xz)

echo "$BOLD${BLUE}Shredding$RESET$BOLD old tar.xz file$RESET"
(shred -n 9 -uzf $SECURE/secure.tar.xz)


