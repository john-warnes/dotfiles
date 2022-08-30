#! /bin/bash

# Script asks for SUDO power
[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"
# TODO: Add a flag to toggle adding user to SUDO or not

function help {
    cat <<EOF
    Usage: $0 [-p] [username] ['full name'] ['SSH Public Key']

    -h|--help                    Display this text.
    -p|--password                Asks for user password interactively
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
eval set -- "${POSITIONAL_ARGS[@]}"
# echo "Postional Args: ${POSITIONAL_ARGS[@]}"

# Check if we have at least three
[[ ${#POSITIONAL_ARGS[@]} < 3 ]] && echo "Error: Invalid arguments" && help

username=${POSITIONAL_ARGS[0]}
fullname=${POSITIONAL_ARGS[1]}
pubkey=${POSITIONAL_ARGS[2]}

if [[ $force == 0 ]] && [ -d "/home/$username" ]; then
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
    echo "Random password generated: '$password'"
fi

# Interactively asks for password
# sudo adduser --gecos "$fullname,,,," $username

# Create the new user and set the password
sudo adduser --disabled-password --gecos "$fullname,,,," $username
echo "$username:$password" | sudo chpasswd

# Save the users password into password.txt
echo "$password" > /home/$username/password.txt
sudo chown $username:$username /home/$username/password.txt
sudo chmod 600 /home/$username/password.txt
echo "Password saved to '/home/$username/password.txt'"

# Make the ssh folder
sudo mkdir /home/$username/.ssh
sudo touch /home/$username/.ssh/authorized_keys

# Copy ssh key into authorized keys
echo $pub_key | sudo tee -a /home/$username/.ssh/authorized_keys

# Set correct ownership and permissions
sudo chmod 755 /home/$username/.ssh
sudo chmod 664 /home/$username/.ssh/authorized_keys
sudo chown -R $username:$username /home/$username/

echo "Sudo-ing user: $username"
sudo usermod -a -G sudo $username
echo "Done."
