#!/usr/bin/env bash

# Check Python version
check_python_version() {
    if ! command -v python3 &> /dev/null; then
        echo "Error: Python 3 is not installed."
        echo "Please install Python 3.8 or higher to continue."
        exit 1
    fi

    local python_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    local required_version="3.8"

    if [ "$(printf '%s\n' "$required_version" "$python_version" | sort -V | head -n1)" != "$required_version" ]; then
        echo "Error: Python version $python_version is not supported."
        echo "This script requires Python $required_version or higher."
        echo "Please upgrade Python and try again."
        exit 1
    fi

    echo "Python version $python_version detected - OK"
}

# Run version check
check_python_version

# Setup without asking for user info
python3 ~/dotfiles/DotSetup.py --skip-user

# Run interactively set asking for user info
# python3 ~/dotfiles/DotSetup.py --install
