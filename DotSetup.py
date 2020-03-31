#!/usr/bin/env python3
# ============================================================================
# @file   DotSetup.py
# @brief  Install my dotfiles
#
# @author John Warnes
#
# @internal
#      Created  Thursday, 04 January 2018
#     Modified  11 March 2020
#     Revision  265
#
# @Copyright  Copyright (c) 2020, John Warnes
#
# ============================================================================

# Required Python3 and Pip3

import os
import sys
import platform
import subprocess

import argparse

from pkg_resources import parse_version

user = {}
SYS_DATA = {}
SETTINGS = {
    "version"    : "3.2",                # Script
    "dotfiles"   : "~/dotfiles",         # Directories
    "backup_file": "~/.dotfiles_Backup", # Files

    # VIM
    "vim_required": "8.0",
    "nvim_recommended": "0.2.0",
}

def box_draw(text):
    print("╔═{:═^{pad}}═╗".format("", pad=len(text)))
    print("║ {:═^{pad}} ║".format(text, pad=len(text)))
    print("╚═{:═^{pad}}═╝".format("", pad=len(text)))

def get_script_path():
    return os.path.dirname(os.path.realpath(sys.argv[0]))

def collect_system_data():
    """
    Used to collect current system state
    """
    global SYS_DATA
    SYS_DATA["home"] = os.path.expanduser("~")
    SYS_DATA["sdir"] = get_script_path()
    SYS_DATA["sfile"] = str(__file__)
    SYS_DATA["os_kind"] = os.name
    SYS_DATA["os"] = platform.system()
    SYS_DATA["os_release"] = platform.release()

    SYS_DATA["vim_version"] = (
        subprocess.check_output("vim --version | head -1 | cut -d ' ' -f 5", shell=True).decode("ascii").strip()
    )

    SYS_DATA["nvim_version"] = (
        subprocess.check_output("nvim --version | head -1 | cut -d ' ' -f 2", shell=True).decode("ascii").strip()[1:]
    )
    # print(os.getcwd())  # Current DIR
    # os.chdir(current_dir)  # Chance DIR

def display_system_data():
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
    print("║ Required Version: {:{pad}} ║".format(SETTINGS["vim_required"], pad=34))
    print("╠═ NEOVIM ═════════════════════════════════════════════╣")
    print("║ Current Version    : {:{pad}} ║".format(SYS_DATA["nvim_version"], pad=31))
    print("║ Recommended Version: {:{pad}} ║".format(SETTINGS["nvim_recommended"], pad=31))
    print("╚══════════════════════════════════════════════════════╝")
    print()

def hasDependencies():
    box_draw("Checking Dependencies")
    print()
    dependencies = True
    if parse_version(SETTINGS["vim_required"]) > parse_version(SYS_DATA["vim_version"]):
        print(" ERROR: Vim version is below the required version")
        dependencies = False
    else:
        print(" Vim version: OK")
    if parse_version(SETTINGS["nvim_recommended"]) > parse_version(SYS_DATA["nvim_version"]):
        print(" Warring: Neovim version is below the recommend version")
    else:
        print(" Neovim version: OK")
    return dependencies

def flat_string(text):
    text = text.replace(" ", "")
    text = text.lower()
    return text

def askUserData():
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

    user["email"] = input(" Email '{}{}@{}.net [Enter] for default': ".format(first.lower(), last[0].lower(), flat_string(user["company"])))
    if user["email"] == '':
        user["email"] = '{}{}@{}.net'.format(first.lower(), last[0].lower(), flat_string(user["company"]))

    user["vim"] = input(" Default console editor '{}' [Enter] for default: ".format("[vim], nvim, nano, code"))
    if user["vim"] == "":
        user["vim"] = "vim"
    print()

def createUserVim():
    print(" Creating user.vim")
    f = open("vim/user.vim", "w")
    f.write("let g:_NAME_    = {}\n".format(user["name"]))
    f.write("let g:_USER_    = {}\n".format(user["user"]))
    f.write("let g:_COMPANY_ = {}\n".format(user["company"]))
    f.write("let g:_EMAIL_   = {}\n".format(user["email"]))
    f.write("let g:_VIM_     = {}\n".format(user["vim"]))
    f.close()


def createUserGit():
    print(" Creating gitconfig")
    f = open("git/gitconfig", "w")
    f.write(
"""[user]
    name = {name}
    email = {email}
[core]
    editor = {vim}
    autocrlf = input
[help]
    autocorrect = 1
[color]
    ui = auto
    branch = auto
    diff = auto
    interactive = auto
    status = auto
[push]
    default = simple
[credential]
    helper = cache --timeout=28800
[alias]
    export = archive -o latest.tar.gz -9 --prefix=latest/
    details = log -n1 -p --format=fuller
    logpretty = log --graph --decorate --pretty=format:'%C(yellow)%h%Creset%C(auto)%d%n%Creset %s %C(green)(%cr) %C(blue)<%an>%Creset'
    logshort = log --graph --decorate --pretty=format:'%C(yellow)%h%Creset -%C(auto)%h %d%Creset %s %C(green)(%cr) %C(blue)<%an>%Creset' --abbrev-commit
    s = status
""".format(name=user["name"], email=user["email"], vim=user["vim"])
    )
    f.close()


def createSysLinks():
    """
    dotifles/vim -> ~/.vim
    dotfiles/vim/vimrc -> ~/.vimrc
    dotfiles/git/gitconfig -> ~/.gitconfig
    """
    symlinks = {
        SYS_DATA["sdir"] + "/vim": SYS_DATA["home"] + "/.vim",
        SYS_DATA["sdir"] + "/vim/vimrc": SYS_DATA["home"] + "/.vimrc",
        SYS_DATA["sdir"] + "/tmux/tmux.conf": SYS_DATA["home"] + "/.tmux.conf",
        SYS_DATA["sdir"] + "/git/gitconfig": SYS_DATA["home"] + "/.gitconfig",
    }
    print()
    print(" Creating symlinks")

    for src, dest in symlinks.items():
        if os.path.isfile(dest):
            os.remove(dest)
        if os.path.islink(dest):
            os.unlink(dest)
        print(" {} -> {}".format(src, dest))
        os.symlink(src, dest)


def exportDOTFILES():
    print()
    print(" Exporting DOTFILES environment variable")
    fn=""
    if SYS_DATA["os"] == "Darwin":
        print(" Darwin detected: Selecting file ~/.bash_profile")

        fn = SYS_DATA["home"] + "/.bash_profile"
        exportline = "export DOTFILES=" + SYS_DATA["sdir"] + "\n"
        autoruncode = "export CLICOLOR=1\nsource $DOTFILES/shell/autorun.sh\n"
    else:
        print(" Selecting file ~/.bashrc")
        fn = SYS_DATA["home"] + "/.bashrc"
        exportline = "export DOTFILES=" + SYS_DATA["sdir"] + "\n"
        autoruncode = "export CLICOLOR=1\nsource $DOTFILES/shell/autorun.sh\n"

    if os.path.isfile(fn) or os.path.islink(fn):
        with open(fn) as f:
            if any(line == exportline for line in f):
                print(" {} already modified".format(fn))
            else:
                print(" modifying {}".format(fn))
                f = open(fn, "a")
                f.write(exportline)
                f.write(autoruncode)
                f.close()

def install():
    askUserData()
    createUserVim()
    createUserGit()
    createSysLinks()
    exportDOTFILES()
    print()
    box_draw("Final Steps")
    print()
    print(' 1. For vim 8.0>: run `vim +PackUpdate`')
    print('    For vim <7.4: run `vim`')
    print(' 2. Ingore any errors in vim and quit with `:q!`')
    print(' 3. Close `exit` all terminal windows and reopen them to finish setup.')
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
    args = parser.parse_args()

    collect_system_data()
    display_system_data()

    if not hasDependencies():
        print()
        print("Error: Missing dependencies.")
        print()
        quit()

    if args.install:
        install()
    elif args.remove:
        remove() # TODO: Add remove
    else:
        print()
        box_draw("Help")
        print(" Usage: ./Dotfiles --install")
        print()


if __name__ == "__main__":
    main()
    exit(0)
