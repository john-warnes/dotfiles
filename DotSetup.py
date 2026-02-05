#!/usr/bin/env python3

# =rev=======================================================================
#  File:      DotSetup.py
#  Brief:     Install Dot files
#  Version:   2.0.1
#
#  Author:    John Warnes
#  Created:   2018 January 04, Thursday
#
#  Modified:  Thursday, 5 February 2026
#  Revision:  286
#
#  License:   Copyright (c) 2026, John Warnes
# ===========================================================================

# Required Python3 and Pip3

import argparse
import configparser
import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Dict, Optional

from pkg_resources import parse_version

SYS_DATA = {}
SETTINGS = {
    # DotSetup Script Version
    "version": "3.5",
    # Directories
    "dotfiles": "~/dotfiles",
    # Files
    "backup_file": "~/.dotfiles_Backup",
    "backup_path": "~/dotfiles/backup",
    # VIM
    "vim_recommended": "8.0",
    "nvim_recommended": "0.2.0",
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
    SYS_DATA["nvim_config"] = os.environ.get("XDG_CONFIG_HOME", SYS_DATA["home"] + "/.config")
    SYS_DATA["script_dir"] = get_script_path()
    SYS_DATA["script_file"] = str(__file__)
    SYS_DATA["os_kind"] = os.name
    SYS_DATA["os"] = platform.system()
    SYS_DATA["os_release"] = platform.release()
    try:
        SYS_DATA["vim_version"] = (
            subprocess.check_output("vim --version | head -1 | cut -d ' ' -f 5", shell=True).decode("ascii").strip()
            or "[Unknown]"
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        SYS_DATA["vim_version"] = "[Not Installed]"

    try:
        SYS_DATA["nvim_version"] = (
            subprocess.check_output("nvim --version | head -1 | cut -d ' ' -f 2", shell=True).decode("ascii").strip()[1:]
            or "[Unknown]"
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        SYS_DATA["nvim_version"] = "[Not Installed]"
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
    print("║ Script File      : {:{pad}} ║".format(SYS_DATA["script_file"], pad=33))
    print("║ Script Directory : {:{pad}} ║".format(SYS_DATA["script_dir"], pad=33))
    print("║ Home Directory   : {:{pad}} ║".format(SYS_DATA["home"], pad=33))
    print("║ Current Version  : {:{pad}} ║".format(SYS_DATA["vim_version"], pad=33))
    print("║ Recommend Version: {:{pad}} ║".format(SETTINGS["vim_recommended"], pad=33)) if not skipUser else False
    print("╠═ NEOVIM ═════════════════════════════════════════════╣")
    print("║ Current Version  : {:{pad}} ║".format(SYS_DATA["nvim_version"], pad=33))
    print("║ Recommend Version: {:{pad}} ║".format(SETTINGS["nvim_recommended"], pad=33)) if not skipUser else False
    print("╚══════════════════════════════════════════════════════╝")
    print()


def has_dependencies(skipUser: bool = False) -> bool:
    box_draw("Checking Dependencies")
    print()
    dependencies = True

    if skipUser:
        return dependencies

    if parse_version(SETTINGS["vim_recommended"]) > parse_version(SYS_DATA["vim_version"]):
        print("Warning: Vim version is below the required version")
    else:
        print("Vim version: OK")
    if parse_version(SETTINGS["nvim_recommended"]) > parse_version(SYS_DATA["nvim_version"]):
        print(" Warning: Neovim version is below the recommend version")
    else:
        print("Neovim version: OK")

    return dependencies


def flat_string(text: str) -> str:
    text = text.replace(" ", "")
    text = text.lower()
    return text


def ask_user_data() -> Dict[str, str]:
    user: Dict[str, str] = {}
    print()
    box_draw("User information")
    print()
    user["name"] = input("Full Name 'John Smith': ")
    if user["name"] == "":
        print("Error! Must enter a fist and last name. example: John Smith")
        sys.exit(1)
    first, *mid, last = user["name"].split()

    user["user"] = input(f"Username '{first[0].lower()}{last.lower()}' [Enter] for default: ")
    if user["user"] == "":
        user["user"] = first[0].lower() + last.lower()

    user["company"] = input("Company Name: ")
    if user["company"] == "":
        print("Error! Must enter a company name.")
        sys.exit(2)

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


def create_user_vim(user: Optional[Dict[str, str]]) -> None:
    if not user:
        return
    print("Creating user.vim")

    vim_user_path = Path(f"{SETTINGS['dotfiles']}/vim/user.vim").expanduser()
    with open(vim_user_path, "w") as f:
        f.write(f"let g:_NAME_    = '{user['name']}'\n")
        f.write(f"let g:_USER_    = '{user['user']}'\n")
        f.write(f"let g:_COMPANY_ = '{user['company']}'\n")
        f.write(f"let g:_EMAIL_   = '{user['email']}'\n")
        f.write(f"let g:_VIM_     = '{user['vim']}'\n")


def create_user_git(user: Optional[Dict[str, str]]) -> None:
    print("Creating gitconfig")

    git_config_path = Path(f"{SETTINGS['dotfiles']}/git/gitconfig").expanduser()
    f = open(git_config_path, "w", encoding="utf-8")
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
                "[init]",
                "\tdefaultBranch = main",
                "",  # Ends in newline
            ]
        )
    )
    f.close()

    # Check if a config file already exists in the home folder, If it does
    # the file we created will not be linked so lets just edit the existing file
    config_file = Path(f"{SYS_DATA['home']}/.gitconfig").expanduser()
    if config_file.is_file() or config_file.is_symlink():
        backup_path = Path(SETTINGS["backup_path"]).expanduser()
        backup_path.mkdir(exist_ok=True)
        shutil.copy(config_file, backup_path / config_file.name)

        print("~/.gitconfig Already exists updating")
        config = configparser.ConfigParser()
        config.read(config_file)

        # Update user information if provided
        if user:
            if "user" in config:
                if "name" in config["user"]:
                    config["user"]["name"] = user["name"]
                if "email" in config["user"]:
                    config["user"]["email"] = user["email"]
            else:
                config["user"] = {"name": user["name"], "email": user["email"]}

        if "alias" not in config:
            config["alias"] = {}
        config["alias"]["s"] = "status"

        if "pull" not in config:
            config["pull"] = {}
        config["pull"]["ff"] = "only"

        if "init" not in config:
            config["init"] = {}
        config["init"]["defaultBranch"] = "main"

        if "credential" not in config:
            config["credential"] = {}
        if "helper" not in config["credential"]:
            config["credential"]["helper"] = "cache --timeout=28800"

        with open(config_file, "w") as file:
            config.write(file)
    else:
        # File does not exits go ahead and link it
        src = Path(f"{SYS_DATA['script_dir']}/git/gitconfig").expanduser()
        dest = Path(f"~/.gitconfig").expanduser()
        os.symlink(src, dest)


def create_folders() -> None:
    # Neovim config directory
    nvim_dir = Path(f"{SYS_DATA['home']}/.config/nvim/").expanduser()
    if not nvim_dir.exists():
        nvim_dir.mkdir(parents=True, exist_ok=True)
        print(f"Created {nvim_dir}")

    # SSH controlmasters directory for connection multiplexing
    ssh_control_dir = Path(f"{SYS_DATA['home']}/.ssh/controlmasters").expanduser()
    if not ssh_control_dir.exists():
        ssh_control_dir.mkdir(parents=True, exist_ok=True)
        ssh_control_dir.chmod(0o700)  # Secure permissions
        print(f"Created {ssh_control_dir} with mode 700")


def install_minpac() -> None:
    """
    Install minpac plugin manager if not already present
    """
    minpac_dir = Path(f"{SYS_DATA['script_dir']}/vim/pack/minpac/opt/minpac").expanduser()

    if minpac_dir.exists() and (minpac_dir / ".git").exists():
        print("minpac already installed")
        return

    print("\nInstalling minpac plugin manager...")
    minpac_dir.parent.mkdir(parents=True, exist_ok=True)

    try:
        subprocess.run(
            ["git", "clone", "--depth=1", "https://github.com/k-takata/minpac.git", str(minpac_dir)],
            check=True,
            capture_output=True
        )
        print("minpac installed successfully")
    except subprocess.CalledProcessError as e:
        print(f"Warning: Failed to install minpac: {e}")
        print("You can manually install it later with:")
        print(f"  git clone --depth=1 https://github.com/k-takata/minpac.git {minpac_dir}")


def create_sys_links() -> None:
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
        if os.path.islink(dest):  # Link already exists
            os.unlink(dest)  # Del
        elif os.path.isfile(dest):  # File already exists
            os.remove(dest)  # Del
        elif os.path.isdir(dest):  # Directory exists
            shutil.rmtree(dest)  # Del directory

        # Create new Link to file
        print(f" {src} -> {dest}")
        os.symlink(src, dest)


def export_dot_files():
    def safe_append(fileName: str, exportLines: list) -> None:
        if not exportLines:
            # No lines to export
            return

        if not (os.path.isfile(fileName) or os.path.islink(fileName)):
            with open(fileName, "a"):
                # Create file if does not exist
                pass

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
        user = ask_user_data()
        create_user_vim(user)

    create_user_git(user)
    create_folders()
    install_minpac()
    create_sys_links()
    export_dot_files()

    print()
    box_draw("Final Steps")
    print()
    print(" 1. For vim 8.0>: run `vim +PackUpdate`")
    print("    For vim <7.4: run `vim`")
    print(" 2. Ignore any errors in vim and quit with `:q!`")
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

    if not has_dependencies(skipUser=args.skipUser):
        print("\nError: Missing dependencies.\n")
        sys.exit(3)

    if args.install or args.skipUser:
        install(skipUser=args.skipUser)

    elif args.remove:
        print("TODO: Add Remove")  # TODO: Add remove
        return
    # elif args.backup:  # TODO: Add Backup
    # elif args.restore: # TODO: Add Restore


if __name__ == "__main__":
    main()
    sys.exit(0)  # Normal
