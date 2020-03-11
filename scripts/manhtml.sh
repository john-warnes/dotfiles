#!/bin/bash
#=================================================================
#  Revision  066
#  Modified  Wednesday, 11 March 2020
#=================================================================

./detectOS.sh

# linux xdg-open "https://www.w3schools.com/TAgs/tag_$1" . ".asp"

echo "os: $OS"

if [[ $OS == 'Linux' ]] || [[ $OS == 'LINUX' ]]; then
    xdg-open "https://www.w3schools.com/TAgs/tag_$1.asp"
elif [[ $OS == 'OSX' ]]; then
    open "https://www.w3schools.com/TAgs/tag_$1.asp"
fi
