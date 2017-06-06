#!/bin/bash -
#===============================================================================
#
#          FILE: lock.sh
#
#         USAGE: ./lock.sh
#
#   DESCRIPTION: encrypt the contents of secure
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: John Warnes (jwarnes), johnwarnes@mail.weber.edu
#  ORGANIZATION: WSU
#       CREATED: 06/06/2017 12:30:05 AM
#      REVISION:  ---
#===============================================================================

SECURE=$DOTFILES/secure
SCRIPTS=$DOTFILES/scripts

if [[ -f "$SCRIPTS/colors.sh" ]]; then
    source $SCRIPTS/colors.sh
fi

if [[ -f $SECURE/secure.tar.xz.gpg ]]; then
    echo "'$BOLD${YELLOW}Note:$RESET$BOLD Shredding old encrypt file$RESET"
    (shred -n 9 -uzf $SECURE/secure.tar.xz.gpg)
fi

echo "$BOLD${BLUE}Compressing$RESET$BOLD files to tar.xz$RESET"
(cd $SECURE && exec tar -c --xz -f secure.tar.xz *)

echo "$BOLD${BLUE}Encrypting$RESET$BOLD tar.xz$RESET"
if [[ "$#" == 1 ]]; then
    (cd $SECURE && exec gpg --passphrase-file <(echo $1) --batch --output secure.tar.xz.gpg -c secure.tar.xz)
else
    (cd $SECURE && exec gpg -c secure.tar.xz)
fi

echo "$BOLD${BLUE}Shredding$RESET$BOLD old tar.xz$RESET"
(shred -n 9 -uzf $SECURE/secure.tar.xz)
