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
    SYS_DATA["sdir"] = get_script_path()
    SYS_DATA["sfile"] = str(__file__)
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
    print("║ Script File     : {:{pad}} ║".format(SYS_DATA["sfile"], pad=34))
    print("║ Script Directory: {:{pad}} ║".format(SYS_DATA["sdir"], pad=34))
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
        print(" Warning: Vim version is below the required version")
    else:
        print(" Vim version: OK")
    if parse_version(SETTINGS["nvim_required"]) > parse_version(SYS_DATA["nvim_version"]):
        print(" Warning: Neovim version is below the recommend version")
    else:
        print(" Neovim version: OK")

    if parse_version(SETTINGS["vim_required"]) > parse_version(SYS_DATA["vim_version"]) and parse_version(
        SETTINGS["nvim_required"]
    ) > parse_version(SYS_DATA["nvim_version"]):
        dependencies = False
        print(" ERROR: Vim or Neovim must be above the required version")

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
    user["name"] = input(" Full Name 'John Smith': ")
    if user["name"] == "":
        print("Error! Must enter a fist and last name. example: John Smith")
        quit()
    first, *mid, last = user["name"].split()

    user["user"] = input(" Username '{}{}' [Enter] for default: ".format(first[0].lower(), last.lower()))
    if user["user"] == "":
        user["user"] = first[0].lower() + last.lower()

    user["company"] = input(" Company Name: ")
    if user["company"] == "":
        print("Error! Must enter a company name.")
        quit()

    user["email"] = input(
        " Email '{}{}@{}.net [Enter] for default': ".format(
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
    print(" Creating user.vim")
    f = open("vim/user.vim", "w")
    f.write("let g:_NAME_    = {}\n".format(user["name"]))
    f.write("let g:_USER_    = {}\n".format(user["user"]))
    f.write("let g:_COMPANY_ = {}\n".format(user["company"]))
    f.write("let g:_EMAIL_   = {}\n".format(user["email"]))
    f.write("let g:_VIM_     = {}\n".format(user["vim"]))
    f.close()


def createUserGit(user: dict) -> None:
    print("Creating gitconfig")
    f = open("git/gitconfig", "w")
    f.write(
        "\n".join(
            [
                "[user]",
                f"	name = {user['name']}" if user else "",
                f"	email = {user['email']}" if user else "",
                "[core]",
                f"	editor = {user['vim']}" if user else "",
                "	autocrlf = input",
                "[help]",
                "	autocorrect = 1",
                "[color]",
                "	ui = auto",
                "	branch = auto",
                "	diff = auto",
                "	interactive = auto",
                "	status = auto",
                "	grep = auto",
                "	pager = true",
                "	decorate = auto",
                "	showbranch = auto",
                "[push]",
                "	default = simple",
                "[credential]",
                "	helper = cache --timeout=28800",
                "[alias]",
                "	export = archive -o latest.tar.gz -9 --prefix=latest/",
                "	details = log -n1 -p --format=fuller",
                r"	logpretty = log --graph --decorate --pretty=format:'%C(yellow)%h%Creset%C(auto)%d%n%Creset %s %C(green)(%cr) %C(blue)<%an>%Creset'",
                r"	logshort = log --graph --decorate --pretty=format:'%C(yellow)%h%Creset -%C(auto)%h %d%Creset %s %C(green)(%cr) %C(blue)<%an>%Creset' --abbrev-commit",
                "	stats-commits = git shortlog -sn --no-merges",
                "	s = status",
                "[pull]",
                "	ff = only",
                "",  # Ends in newline
            ]
        )
    )
    f.close()


def createFolders():
    dir = SYS_DATA["home"] + "/.config/nvim/"
    if os.path.isdir(dir):
        return
    else:
        os.makedirs(dir)


def createSysLinks():
    """
    {DOT_FILES}/vim -> ~/.vim
    {DOT_FILES}/vim/vimrc -> ~/.vimrc
    {DOT_FILES}/git/gitconfig -> ~/.gitconfig
    {DOT_FILES}/nvim/init.vim -> ~/.config/nvim/init.vim

    """
    symlinks = {
        SYS_DATA["sdir"] + "/vim": SYS_DATA["home"] + "/.vim",
        SYS_DATA["sdir"] + "/vim/vimrc": SYS_DATA["home"] + "/.vimrc",
        SYS_DATA["sdir"] + "/tmux/tmux.conf": SYS_DATA["home"] + "/.tmux.conf",
        SYS_DATA["sdir"] + "/git/gitconfig": SYS_DATA["home"] + "/.gitconfig",
        SYS_DATA["sdir"] + "/nvim/init.vim": SYS_DATA["home"] + "/.config/nvim/init.vim",
    }
    print()
    print("Creating symlinks")

    for src, dest in symlinks.items():
        if os.path.isfile(dest):
            os.remove(dest)
        if os.path.islink(dest):
            os.unlink(dest)
        print(" {} -> {}".format(src, dest))
        os.symlink(src, dest)


def exportDotFiles():
    def safe_append(fileName: str, exportLines: list[str]) -> None:
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

    print()
    print("Exporting DOT_FILES environment variable")
    fn = ""
    if SYS_DATA["os"] == "Darwin":
        print(" Darwin detected: Selecting file '~/.bash_profile' and '~/.zshrc'")

        fn = SYS_DATA["home"] + "/.bash_profile"
        exportline = "export DOT_FILES=" + SYS_DATA["sdir"] + "\n"
        autoruncode = "export CLICOLOR=1\nsource $DOT_FILES/shell/autorun.sh\n"
        safe_append(fn, [exportline, autoruncode])

        fn = SYS_DATA["home"] + "/.zshrc"
        zshprompt = "prompt='%F{028}%n@%m %F{025}%~%f %% '"
        safe_append(fn, [exportline, autoruncode, zshprompt])
    else:

        safe_append(
            f'{SYS_DATA["home"]}/.bashrc',
            [
                f'export DOT_FILES={SYS_DATA["sdir"]}\n',
                "export CLICOLOR=1\n",
                "source $DOT_FILES/shell/autorun.sh\n",
            ],
        )


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
    # process command line arguments
    parser = argparse.ArgumentParser()
    xorgroup = parser.add_mutually_exclusive_group()
    xorgroup.add_argument("-i", "--install", help="Install Files", action="store_true", default=False)
    xorgroup.add_argument("-r", "--remove", help="Remove Files", action="store_true", default=False)
    # parser.add_argument('-', help="Column to show", type=int, default=16, dest="col")
    parser.add_argument(
        "--skip-user", help="Install, Skipping user setup", action="store_true", default=False, dest="skipUser"
    )
    args = parser.parse_args()

    collect_system_data()
    display_system_data(skipUser=args.skipUser)

    if not hasDependencies(skipUser=args.skipUser):
        print("\nError: Missing dependencies.\n")
        quit()

    if args.install or args.skipUser:
        install(skipUser=args.skipUser)
    elif args.remove:
        remove()  # TODO: Add remove
    else:
        print()
        box_draw("Help")
        print(" Usage: ./DotSetup --install")
        print()
    return


if __name__ == "__main__":
    main()
    exit(0)
