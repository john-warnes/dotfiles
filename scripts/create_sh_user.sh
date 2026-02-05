#!/usr/bin/env bash

# TODO: Add a flag to toggle adding user to SUDO or not

# Script asks for SUDO power
[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"

function help {
    cat <<EOF
    Usage: $0 [-p] [username] ['full name'] ['SSH Public Key']

    -h | --help                  Display this text.
    -p | --password              Asks for user password interactively
                                 else password will be random '~/password.txt'
EOF
    exit
}

# If 1 then ask for the password on command line
ask_password=0
force=0

POSITIONAL_ARGS=()

while (("$#")); do
    case "$1" in
    -\? | -h | --help)
        shift 1
        help
        ;;
    -p | --password)
        shift
        ask_password=1
        ;;
    -f | --force)
        shift
        force=1
        ;;
    --) # end argument parsing
        shift
        break
        ;;
    -* | --*=) # unsupported flags
        echo "Error: Unsupported flag $1" >&2
        help
        exit 1
        ;;
    *) # preserve positional arguments
        POSITIONAL_ARGS+=("$1")
        shift
        ;;
    esac
done

# set positional arguments in their proper place
set -- "${POSITIONAL_ARGS[@]}"
# echo "Positional Args: ${POSITIONAL_ARGS[@]}"

# Check if we have at least three
[[ ${#POSITIONAL_ARGS[@]} -lt 3 ]] && echo "Error: Invalid arguments" && help

username=${POSITIONAL_ARGS[0]}
fullname=${POSITIONAL_ARGS[1]}
pub_key=${POSITIONAL_ARGS[2]}

# Validate username format (alphanumeric, dash, underscore only)
if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "Error: Invalid username format. Use lowercase letters, numbers, dash, and underscore only."
    exit 1
fi

# Validate SSH public key format (basic check)
if [[ ! "$pub_key" =~ ^(ssh-rsa|ssh-ed25519|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521)[[:space:]] ]]; then
    echo "Error: Invalid SSH public key format. Must start with ssh-rsa, ssh-ed25519, or ecdsa-sha2-*"
    exit 1
fi

if [[ $force == 0 ]] && [[ -d "/home/$username" ]]; then
    echo "Error: User home directory already exists. (-f to force)"
    exit 1
fi

echo "New Username: $username"

if [[ $ask_password == 1 ]]; then
    # Ask for password for new user
    read -s -p "New Password: " password
    echo ""
fi

# If password is empty set it to random
if [ -z "$password" ]; then
    password=$(head /dev/urandom | LC_ALL=C tr -dc A-Za-z0-9 | head -c 13)
    echo "Random password generated: \`$password\`"
fi

# Interactively asks for password
# sudo adduser --gecos "$fullname,,,," $username

# Create the new user and set the password
sudo adduser --disabled-password --gecos "$fullname,,,," "$username"
# Use here-string to safely pass password with special characters
printf '%s:%s\n' "$username" "$password" | sudo chpasswd

# Save the users password into password.txt
echo "WARNING: Storing password in plain text file (security risk)"
# Use tee with sudo to safely write password (avoids shell expansion issues)
printf '%s' "$password" | sudo tee "/home/$username/password.txt" > /dev/null
sudo chown "$username":"$username" "/home/$username/password.txt"
sudo chmod 600 "/home/$username/password.txt"
echo "Password saved to \`/home/$username/password.txt\`"

# Make the ssh folder
sudo mkdir -p "/home/$username/.ssh"

# Copy ssh key into authorized keys (safe variable expansion)
printf '%s\n' "$pub_key" | sudo tee "/home/$username/.ssh/authorized_keys" > /dev/null

# Set correct ownership and permissions for .ssh
sudo chmod 700 "/home/$username/.ssh"
sudo chmod 600 "/home/$username/.ssh/authorized_keys"
sudo chown -R "$username":"$username" "/home/$username/.ssh"

echo "Sudo-ing user: \`$username\`"
sudo usermod -a -G sudo "$username"
echo "Done."
