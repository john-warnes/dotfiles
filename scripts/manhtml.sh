#!/bin/bash
#=================================================================
#  Revision  055
#  Modified  Wednesday, 17 January 2018
#=================================================================

# linux xdg-open "https://www.w3schools.com/TAgs/tag_$1" . ".asp"
if [[ $OS == 'Linux' ]]; then
    xdg-open "https://www.w3schools.com/TAgs/tag_$1.asp"
elif [[ $OS == 'OSX' ]]; then
    open "https://www.w3schools.com/TAgs/tag_$1.asp"
fi
