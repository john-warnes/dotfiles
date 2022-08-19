#!/usr/bin/env python3
# ============================================================================
# @file   DotSetup.py
# @brief  Install Dot files
#
# @author John Warnes
#
# @internal
#      Created  2018 January 04, Thursday
#     Modified  2022 Aug 18, Thursday
#     Revision  280
#
# @copyright  Copyright (c) 2022, John Warnes
# ============================================================================

# Required Python3 and Pip3

import argparse
import os
import platform
import subprocess
import sys

from pkg_resources import parse_version

SYS_DATA = {}
SETTINGS = {
    # DotSetup Script Version
    "version": "3.5",
    # Directories
    "dotfiles": "~/dotfiles",
    # Files
    "backup_file": "~/.dotfiles_Backup",
    # VIM
    "vim_required": "8.0",
    "nvim_required": "0.2.0",
}


def box_draw(text: str) -> None:
    print("╔═{:═^{pad}}═╗".format("", pad=len(text)))
    print("║ {:═^{pad}} ║".format(text, pad=len(text)))
    print("╚═{:═^{pad}}═╝".format("", pad=len(text)))


def get_script_path() -> str:
    return os.path.dirname(os.path.realpath(sys.argv[0]))


def collect_system_data():
    """
    Used to collect current system state
    """
    SYS_DATA["home"] = os.path.expanduser("~")
    SYS_DATA["nvim_config"] = BAR = os.environ.get("XDG_CONFIG_HOME", SYS_DATA["home"] + "/.config/nvim/")  # None
    SYS_DATA["script_dir"] = get_script_path()
    SYS_DATA["script_file"] = str(__file__)
    SYS_DATA["os_kind"] = os.name
    SYS_DATA["os"] = platform.system()
    SYS_DATA["os_release"] = platform.release()
    SYS_DATA["vim_version"] = (
        subprocess.check_output("vim --version | head -1 | cut -d ' ' -f 5", shell=True).decode("ascii").strip()
        or "[Unknown]"
    )
    SYS_DATA["nvim_version"] = (
        subprocess.check_output("nvim --version | head -1 | cut -d ' ' -f 2", shell=True).decode("ascii").strip()[1:]
        or "[Unknown]"
    )
    # print(os.getcwd())  # Current DIR
    # os.chdir(current_dir)  # Chance DIR


def display_system_data(skipUser: bool = False):
    """
    Display current system information
    """
    print("╔═ OS ═════════════════════════════════════════════════╗")
    print("║ Kind   : {:{pad}} ║".format(SYS_DATA["os_kind"], pad=43))
    print("║ OS     : {:{pad}} ║".format(SYS_DATA["os"], pad=43))
    print("║ Release: {:{pad}} ║".format(SYS_DATA["os_release"], pad=43))
    print("╠═ VIM ════════════════════════════════════════════════╣")
    print("║ Script File     : {:{pad}} ║".format(SYS_DATA["script_file"], pad=34))
    print("║ Script Directory: {:{pad}} ║".format(SYS_DATA["script_dir"], pad=34))
    print("║ Home Directory  : {:{pad}} ║".format(SYS_DATA["home"], pad=34))
    print("║ Current Version : {:{pad}} ║".format(SYS_DATA["vim_version"], pad=34))
    print("║ Required Version: {:{pad}} ║".format(SETTINGS["vim_required"], pad=34)) if not skipUser else False
    print("╠═ NEOVIM ═════════════════════════════════════════════╣")
    print("║ Current Version  : {:{pad}} ║".format(SYS_DATA["nvim_version"], pad=33))
    print("║ Required Version : {:{pad}} ║".format(SETTINGS["nvim_required"], pad=33)) if not skipUser else False
    print("╚══════════════════════════════════════════════════════╝")
    print()


def hasDependencies(skipUser: bool = False) -> bool:
    box_draw("Checking Dependencies")
    print()
    dependencies = True

    if skipUser:
        return dependencies

    if parse_version(SETTINGS["vim_required"]) > parse_version(SYS_DATA["vim_version"]):
        print("Warning: Vim version is below the required version")
    else:
        print("Vim version: OK")
    if parse_version(SETTINGS["nvim_required"]) > parse_version(SYS_DATA["nvim_version"]):
        print(" Warning: Neovim version is below the recommend version")
    else:
        print("Neovim version: OK")

    if parse_version(SETTINGS["vim_required"]) > parse_version(SYS_DATA["vim_version"]) and parse_version(
        SETTINGS["nvim_required"]
    ) > parse_version(SYS_DATA["nvim_version"]):
        dependencies = False
        print("ERROR: Vim or Neovim must be above the required version")

    return dependencies


def flat_string(text: str) -> str:
    text = text.replace(" ", "")
    text = text.lower()
    return text


def askUserData() -> dict:
    user = {}
    print()
    box_draw("User information")
    print()
    user["name"] = input("Full Name 'John Smith': ")
    if user["name"] == "":
        print("Error! Must enter a fist and last name. example: John Smith")
        exit(1)
    first, *mid, last = user["name"].split()

    user["user"] = input("Username '{}{}' [Enter] for default: ".format(first[0].lower(), last.lower()))
    if user["user"] == "":
        user["user"] = first[0].lower() + last.lower()

    user["company"] = input("Company Name: ")
    if user["company"] == "":
        print("Error! Must enter a company name.")
        exit(2)

    user["email"] = input(
        "Email '{}{}@{}.net [Enter] for default': ".format(
            first.lower(), last[0].lower(), flat_string(user["company"])
        )
    )
    if user["email"] == "":
        user["email"] = "{}{}@{}.net".format(first.lower(), last[0].lower(), flat_string(user["company"]))

    user["vim"] = input(" Default console editor '{}' [Enter] for default: ".format("[vim], nvim, nano, code"))
    if user["vim"] == "":
        user["vim"] = "vim"

    print("")
    return user


def createUserVim(user: dict) -> None:
    if not user:
        return
    print("Creating user.vim")
    f = open("vim/user.vim", "w")
    f.write(f"let g:_NAME_    = {user['name']}\n")
    f.write(f"let g:_USER_    = {user['user']}\n")
    f.write(f"let g:_COMPANY_ = {user['company']}\n")
    f.write(f"let g:_EMAIL_   = {user['email']}\n")
    f.write(f"let g:_VIM_     = {user['vim']}\n")
    f.close()


def createUserGit(user: dict) -> None:
    print("Creating gitconfig")
    f = open("git/gitconfig", "w")
    f.write(
        "\n".join(
            [
                "[user]",
                f"	name  = {user['name']}" if user else "",
                f"	email = {user['email']}" if user else "",
                "[core]",
                f"	editor = {user['vim']}" if user else "",
                "	autocrlf = input",
                "[help]",
                "	autocorrect = 1",
                "[color]",
                "	ui          = auto",
                "	branch      = auto",
                "	diff        = auto",
                "	interactive = auto",
                "	status      = auto",
                "	grep        = auto",
                "	pager       = true",
                "	decorate    = auto",
                "	showbranch  = auto",
                "[push]",
                "	default     = simple",
                "[credential]",
                "	helper      = cache --timeout=28800",  # Don't ask for a password for 8 hours
                "[alias]",
                "	s             = status",
                "	export        = archive -o latest.tar.gz -9 --prefix=latest/",
                "	details       = log -n1 -p --format=fuller",
                r"	logpretty    = log --graph --decorate --pretty=format:'%C(yellow)%h%Creset%C(auto)%d%n%Creset %s %C(green)(%cr) %C(blue)<%an>%Creset'",
                r"	logshort     = log --graph --decorate --pretty=format:'%C(yellow)%h%Creset -%C(auto)%h %d%Creset %s %C(green)(%cr) %C(blue)<%an>%Creset' --abbrev-commit",
                "	stats-commits = shortlog -sn --no-merges",  # Shows number of lines / commit by author for the current branch
                "[pull]",
                "	ff = only",
                "",  # Ends in newline
            ]
        )
    )
    f.close()


def createFolders() -> None:
    dir = f"{SYS_DATA['home']}/.config/nvim/"
    if os.path.isdir(dir):
        return
    os.makedirs(dir)


def createSysLinks() -> None:
    """
    {DOT_FILES}/vim -> ~/.vim
    {DOT_FILES}/vim/vimrc -> ~/.vimrc
    {DOT_FILES}/git/gitconfig -> ~/.gitconfig
    {DOT_FILES}/nvim/init.vim -> ~/.config/nvim/init.vim

    """
    home = SYS_DATA["home"]
    dot_files = SYS_DATA["script_dir"]
    symlinks = {
        f"{dot_files}/vim": f"{home}/.vim",
        f"{dot_files}/vim/vimrc": f"{home}/.vimrc",
        f"{dot_files}/tmux/tmux.conf": f"{home}/.tmux.conf",
        f"{dot_files}/git/gitconfig": f"{home}/.gitconfig",
        f"{dot_files}/nvim/init.vim": f"{home}/.config/nvim/init.vim",
    }
    print("\nCreating symlinks")

    for src, dest in symlinks.items():
        if os.path.isfile(dest):  # File already exists
            os.remove(dest)  # Del
        if os.path.islink(dest):  # Link already exists
            os.unlink(dest)  # Del

        # Create new Link to file
        print(" {} -> {}".format(src, dest))
        os.symlink(src, dest)


def exportDotFiles():
    def safe_append(fileName: str, exportLines: list) -> None:
        if not exportLines:
            # No lines to export
            return

        if not (os.path.isfile(fileName) or os.path.islink(fileName)):
            print(f" Error file not found: {fileName}")
            return

        with open(fileName) as readFile:
            for line in readFile:
                if line in exportLines:
                    exportLines.remove(line)
                    print(" Skip line: {}".format(line.replace("\n", "")))

        with open(fileName, "a") as appendFile:
            for exportLine in exportLines:
                print(" Add line: {}".format(exportLine.replace("\n", ""), fileName))
                appendFile.write(exportLine)

    print("\nExporting DOT_FILES environment variable")
    exportLines = [
        f"export DOT_FILES={SYS_DATA['script_dir']}\n",
        "export CLICOLOR=1\n",
        "source $DOT_FILES/shell/autorun.sh\n",
    ]

    if SYS_DATA["os"] == "Darwin":
        print(" Darwin detected: Appending files '~/.bash_profile' and '~/.zshrc'")

        # ~/.bash_profile
        safe_append(f"{SYS_DATA['home']}/.bash_profile", exportLines)

        # ~/.zshrc
        safe_append(
            f"{SYS_DATA['home']}/.zshrc",
            [*exportLines, "prompt='%F{028}%n@%m %F{025}%~%f %% '"],
        )
    else:
        # ~/.bashrc
        safe_append(f"{SYS_DATA['home']}/.bashrc", exportLines)


def install(skipUser: bool = False):
    user = None
    if not skipUser:
        user = askUserData()
        createUserVim(user)

    createUserGit(user)
    createFolders()
    createSysLinks()
    exportDotFiles()

    print()
    box_draw("Final Steps")
    print()
    print(" 1. For vim 8.0>: run `vim +PackUpdate`")
    print("    For vim <7.4: run `vim`")
    print(" 2. Ingore any errors in vim and quit with `:q!`")
    print(" 3. Close `exit` all terminal windows and reopen them to finish setup.")
    print()


def main():
    """
    Main
    """
    # Processor for command line arguments
    parser = argparse.ArgumentParser()

    # Group
    xorgroup = parser.add_mutually_exclusive_group()
    xorgroup.add_argument("-i", "--install", help="Install Files", action="store_true", default=False)
    xorgroup.add_argument("-r", "--remove", help="Remove Files", action="store_true", default=False)

    # parser.add_argument('-', help="Column to show", type=int, default=16, dest="col")
    parser.add_argument(
        "--skip-user", help="Install, Skipping user setup", action="store_true", default=False, dest="skipUser"
    )

    # Parse the given args
    args = parser.parse_args()

    collect_system_data()
    display_system_data(skipUser=args.skipUser)

    if not hasDependencies(skipUser=args.skipUser):
        print("\nError: Missing dependencies.\n")
        exit(3)

    if args.install or args.skipUser:
        install(skipUser=args.skipUser)

    elif args.remove:
        print("TODO: Add Remove")  # TODO: Add remove
        return
    # elif args.backup:  # TODO: Add Backup
    # elif args.restore: # TODO: Add Restore


if __name__ == "__main__":
    main()
    exit(0)  # Normal
