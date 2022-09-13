#!/bin/bash

if [[ "/bin/bash" == "$SHELL" ]]; then
    pushd $(dirname -- "${BASH_SOURCE[0]}")
else
    pushd $(dirname -- "$0")
fi

# Setup without asking for user info
python3 ~/dotfiles/DotSetup.py --skip-user

# Run interactively set asking for user info
# python3 ~/dotfiles/DotSetup.py --install

popd