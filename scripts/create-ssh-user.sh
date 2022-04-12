#! /bin/bash

# TODO: Add a flag to toggle adding user to SUDO or not

function help {
cat <<EOF
    Usage: $0 [username] ["full name"] ["SSH Public Key"]

    -h|--help                    Display this text.
EOF
exit
}

POSITIONAL_ARGS=()

while (( "$#" )); do
    case "$1" in
    -?|-h|--help)
        shift 1
        help
    ;;
    --) # end argument parsing
        shift
        break
    ;;
    -*|--*=) # unsupported flags
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

# Check if we have at least one
[[ ${#POSITIONAL_ARGS[@]} < 3 ]] && help


username=${POSITIONAL_ARGS[0]}
fullname=${POSITIONAL_ARGS[1]}
pubkey=${POSITIONAL_ARGS[2]}

echo "Adding user: $username"
echo ""

sudo adduser $username --gecos "$fullname,,,,"

sudo mkdir /home/$username/.ssh
sudo touch /home/$username/.ssh/authorized_keys
echo $pub_key | sudo tee -a /home/$username/.ssh/authorized_keys
sudo chmod 755 /home/$username/.ssh
sudo chmod 664 /home/$username/.ssh/authorized_keys
sudo chown -R $username:$username /home/$username/

echo "Sudo-ing user: $username"
sudo usermod -a -G sudo $username
echo "Done."