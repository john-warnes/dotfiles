#!/bin/bash

# Written by John Warnes
#=================================================================
#  Revision  10
#  Modified  Friday, 17 November 2017
#=================================================================

#set -euo pipefail
#IFS=$'\n\t'

echo ""
echo "##### Installing dotfiles OSX pre-install requirements #####"
echo ""
echo "############ Launching Homebrew Installer ##################"
echo ""
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
echo "installing brew git"

brew update
brew install git
brew link git

echo ""
echo "################### Installing brew bash ######################"
echo ""
brew update
brew install bash

echo "################# Installing bash-completion ##################"
brew install bash-completion

echo ""
echo " ################################################"
echo " ##  Pre-install done run:                     ##"
echo " ##        bash ./Dotfiles.sh --administrator  ##"
echo " ################################################"
echo ""
echo ""
#   bash Dotfiles.sh --install

#   try to update login bash
#   sudo bash -c 'echo /user/local/bin/bash >> /etc/shells
#   chsh -s /usr/local/bin/bash

