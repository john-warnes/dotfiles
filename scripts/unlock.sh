#!/usr/bin/env bash

# =rev=======================================================================
#          File: unlock.sh
#        Author: John Warnes, john@savagebee.org
#       Created: 06/06/2017 12:39:00 AM
#       Version: 2.0
#      Revision: 074
#      Modified: Wednesday, 4 February 2026
#       License: MIT
# ===========================================================================

SECURE=$DOT_FILES/secure
SCRIPTS=$DOT_FILES/scripts
PULL=false

function help {
    cat <<EOF
    Usage: $0 [options] [passphrase]

    Decrypt the contents of the secure directory.
    Note: Decryption automatically detects the cipher used (set via lock.sh --cipher).

    -d | --dir <directory>       Specify directory to unlock (default: \$DOT_FILES/secure)
    --pull                       Pull from git repository before decryption
    -h | --help                  Display this text

    [passphrase]                 Optional passphrase for non-interactive decryption

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
    --pull)
        PULL=true
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

if ! [[ -d "$SECURE" ]]; then
    echo "$BOLD${RED}Error:$RESET$BOLD No secure directory detected: run './Dotfiles --decrypt' $RESET"
    exit 1
fi

if [[ "$PULL" == true ]]; then
    (cd "$SECURE" && git reset --hard)
    (cd "$SECURE" && git pull --all)
fi

# Find all secure files matching the pattern
shopt -s nullglob
SECURE_FILES=("$SECURE"/secure.*.tar.xz.gpg)
shopt -u nullglob

if [[ ${#SECURE_FILES[@]} -eq 0 ]]; then
    echo "$BOLD${RED}Error:$RESET$BOLD Nothing to unlock as no secure file found$RESET"
    exit 1
fi

# Sort files and get the newest (last in sorted order due to timestamp format)
NEWEST_FILE=$(printf '%s\n' "${SECURE_FILES[@]}" | sort | tail -n 1)

# Warn if multiple files exist
if [[ ${#SECURE_FILES[@]} -gt 1 ]]; then
    echo "$BOLD${YELLOW}Warning:$RESET$BOLD Found ${#SECURE_FILES[@]} encrypted files$RESET"
    echo "$BOLD${YELLOW}Using newest:$RESET $(basename "$NEWEST_FILE")$RESET"
    echo "$BOLD${YELLOW}Recommendation:$RESET Consider shredding old files after verification:$RESET"
    for file in "${SECURE_FILES[@]}"; do
        if [[ "$file" != "$NEWEST_FILE" ]]; then
            echo "  shred -n 9 -uzf \"$file\""
        fi
    done
    echo ""
fi

SECURE_BASENAME=$(basename "$NEWEST_FILE" .gpg)
SECURE_TAR=$(basename "$NEWEST_FILE" .tar.xz.gpg).tar.xz

if [[ -f "$SECURE/$SECURE_TAR" ]]; then
    echo "$BOLD${YELLOW}Note:$RESET$BOLD Shredding old tar.xz file$RESET"
    (exec "$SHRED" -n 9 -uzf "$SECURE/$SECURE_TAR")
fi

echo "$BOLD${BLUE}Unencrypting$RESET$BOLD $(basename "$NEWEST_FILE")$RESET"
if [[ $# -eq 1 ]]; then
    (cd "$SECURE" && gpg -d --batch --passphrase-file <(echo "$1") --output "$SECURE_TAR" "$(basename "$NEWEST_FILE")") || {
        echo "$BOLD${RED}Error:$RESET$BOLD Decryption failed$RESET" >&2
        exit 1
    }
else
    (cd "$SECURE" && gpg -d --output "$SECURE_TAR" "$(basename "$NEWEST_FILE")") || {
        echo "$BOLD${RED}Error:$RESET$BOLD Decryption failed or cancelled$RESET" >&2
        exit 1
    }
fi

echo "$BOLD${BLUE}Decompressing tar.zx to files$RESET"
(cd "$SECURE" && exec tar -xf "$SECURE_TAR")

echo "$BOLD${BLUE}Shredding$RESET$BOLD used tar.xz file$RESET"
("$SHRED" -n 9 -uzf "$SECURE/$SECURE_TAR")
