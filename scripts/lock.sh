#!/usr/bin/env bash

# =rev=======================================================================
#          File: lock.sh
#        Author: John Warnes, john@savagebee.org
#       Created: 06/06/2017 12:35:00 AM
#       Version: 2.0
#      Revision: 075
#      Modified: Wednesday, 4 February 2026
#       License: MIT
#===============================================================================

SECURE=$DOT_FILES/secure
SCRIPTS=$DOT_FILES/scripts

DATE=$(date +%Y-%m-%d)
PUSH=false
CIPHER="AES256"

function help {
    cat <<EOF
    Usage: $0 [options] [passphrase]

    Encrypt the contents of the secure directory.

    -d | --dir <directory>       Specify directory to secure (default: \$DOT_FILES/secure)
    --cipher <algorithm>         Encryption algorithm (default: AES256)
                                 Options: AES256, AES192, AES128, 3DES, CAST5, etc.
    --push                       Push encrypted file to git repository after encryption
    -h | --help                  Display this text

    [passphrase]                 Optional passphrase for non-interactive encryption

EOF
    exit
}

POSITIONAL_ARGS=()

while (("$#")); do
    case "$1" in
    -d | --dir)
        [[ $# -lt 2 ]] && echo "Error: --dir requires a directory argument" >&2 && exit 1
        SECURE="$2"
        shift 2
        ;;
    --cipher)
        [[ $# -lt 2 ]] && echo "Error: --cipher requires an algorithm argument" >&2 && exit 1
        CIPHER="$2"
        shift 2
        ;;
    --push)
        PUSH=true
        shift
        ;;
    -h | --help)
        shift
        help
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

if [[ -f "$SCRIPTS/colors.sh" ]]; then
    source "$SCRIPTS/colors.sh"
fi

if [[ -f "$SCRIPTS/detectOS.sh" ]]; then
    source "$SCRIPTS/detectOS.sh"
fi

SHRED='shred'
if [[ $OS == 'OSX' ]]; then
    SHRED='gshred'
fi

# Check if SECURE directory exists
if [[ ! -d "$SECURE" ]]; then
    echo "ERROR: Directory $SECURE not found" >&2
    exit 1
fi

# Generate timestamp for filename
TIMESTAMP=$(date +%Y-%m-%dT%H.%M.%S.%N | sed 's/\([0-9]\{4\}\)[0-9]*$/\1/')
SECURE_FILE="secure.${TIMESTAMP}.tar.xz"
SECURE_GPG="secure.${TIMESTAMP}.tar.xz.gpg"

echo "$BOLD${BLUE}Compressing$RESET$BOLD files to tar.xz$RESET"
(cd "$SECURE" && exec tar --exclude='secure.*.tar.xz.gpg' -c --xz -f "$SECURE_FILE" *)

echo "$BOLD${BLUE}Encrypting$RESET$BOLD tar.xz with $CIPHER$RESET"
if [[ "$#" -eq 1 ]]; then
    (cd "$SECURE" && gpg --cipher-algo "$CIPHER" --passphrase-file <(echo "$1") --batch --output "$SECURE_GPG" -c "$SECURE_FILE") || {
        echo "$BOLD${RED}Error:$RESET$BOLD Encryption failed$RESET" >&2
        ("$SHRED" -n 9 -uzf "$SECURE/$SECURE_FILE")
        exit 1
    }
else
    (cd "$SECURE" && gpg --cipher-algo "$CIPHER" -c "$SECURE_FILE") || {
        echo "$BOLD${RED}Error:$RESET$BOLD Encryption failed or cancelled$RESET" >&2
        ("$SHRED" -n 9 -uzf "$SECURE/$SECURE_FILE")
        exit 1
    }
fi

echo "$BOLD${BLUE}Shredding$RESET$BOLD used tar.xz$RESET"
("$SHRED" -n 9 -uzf "$SECURE/$SECURE_FILE")

# Shred all old encrypted files
echo "$BOLD${BLUE}Shredding$RESET$BOLD old encrypted files$RESET"
shopt -s nullglob
for old_file in "$SECURE"/secure.*.tar.xz.gpg; do
    if [[ "$(basename "$old_file")" != "$SECURE_GPG" ]]; then
        echo "  Shredding old file: $(basename "$old_file")"
        ("$SHRED" -n 9 -uzf "$old_file")
    fi
done
shopt -u nullglob

if [[ "$PUSH" == true ]]; then
    if [[ -d "$SECURE" ]]; then
        if [[ -f "$SECURE/$SECURE_GPG" ]]; then
            (cd "$SECURE" && git add -A)
            (cd "$SECURE" && git commit -m "Updated Secure File $DATE")
            (cd "$SECURE" && git push)
        else
            echo "ERROR File $SECURE/$SECURE_GPG not found"
        fi
    else
        echo "ERROR Directory $SECURE not found"
    fi
fi
