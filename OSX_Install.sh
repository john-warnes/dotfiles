#!/bin/bash

# Written by John Warnes
#=================================================================
#  Revision  5
#  Modified  Friday, 17 November 2017
#=================================================================

#set -euo pipefail
#IFS=$'\n\t'

set -o nounset
clear

echo "Installing OSX pre-install requirements"
echo "checking git"
echo "  if you see a xcode popup"
echo "  complete the install then"
echo "  Hit [Enter] to continue."
git -v
read -n 1 -p "Hit [Enter] to continue."

echo "Launching Homebrew Installer"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
echo "installing brew git"

brew update
brew install git
brew link git

echo "installing brew bash"
brew update
brew install bash

echo "installing bash-completion"
brew install bash-completion


echo ""
echo ""
echo "Pre-install done run: 'bash ./Dotfiles.sh --administrator"
echo ""
#   bash Dotfiles.sh --install

#   try to update login bash
#   sudo bash -c 'echo /user/local/bin/bash >> /etc/shells
#   chsh -s /usr/local/bin/bash

set +o nounset
