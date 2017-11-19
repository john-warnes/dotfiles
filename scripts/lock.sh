#!/bin/bash -
#===============================================================================
#
#          FILE: lock.sh
#
#         USAGE: ./lock.sh
#
#   DESCRIPTION: encrypt the contents of secure
#
#        AUTHOR: John Warnes (jwarnes), johnwarnes@mail.weber.edu
#       CREATED: 06/06/2017 12:30:05 AM
#===============================================================================

SECURE=$DOTFILES/secure
SCRIPTS=$DOTFILES/scripts

DATE=`date +%Y-%m-%d`

if [[ -f "$SCRIPTS/colors.sh" ]]; then
    source $SCRIPTS/colors.sh
fi

if [[ -f "$SCRIPTS/detectOS" ]]; then
    source $SCRIPTS/detectOS
fi

SHRED='shred'
if [[ $OS == 'OSX' ]]; then
    SHRED='gshred'
fi

if [[ -f $SECURE/secure.tar.xz.gpg ]]; then
    echo "'$BOLD${YELLOW}Note:$RESET$BOLD Shredding old encrypt file$RESET"
    ($SHRED -n 9 -uzf $SECURE/secure.tar.xz.gpg)
fi

echo "$BOLD${BLUE}Compressing$RESET$BOLD files to tar.xz$RESET"
(cd $SECURE && exec tar --exclude=secure.tar.xz.gpg -c --xz -f secure.tar.xz *)

echo "$BOLD${BLUE}Encrypting$RESET$BOLD tar.xz$RESET"
if [[ "$#" == 1 ]]; then
    (cd $SECURE && exec gpg --passphrase-file <(echo $1) --batch --output secure.tar.xz.gpg -c secure.tar.xz)
else
    (cd $SECURE && exec gpg -c secure.tar.xz)
fi

echo "$BOLD${BLUE}Shredding$RESET$BOLD old tar.xz$RESET"
($SHRED -n 9 -uzf $SECURE/secure.tar.xz)

if [[ -d $SECURE ]]; then
    if [[ -f $SECURE/secure.tar.xz.gpg ]]; then
       (cd $SECURE && git add -u)
       (cd $SECURE && git commit -m "Updated Secure File $DATE")
       (cd $SECURE && git push)
    else
        echo "ERROR File $SECURE/secure.tar.xz.gpg not found"
    fi
else
    echo "ERROR Directory $SECURE not found"
fi
