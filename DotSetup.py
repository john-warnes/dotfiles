#!/usr/bin/env python3

# =rev=======================================================================
#  File:      DotSetup.py
#  Brief:     Install Dot files
#  Version:   4.0.1
#
#  Author:    John Warnes
#  Created:   2018 January 04, Thursday
#
#  Modified:  Friday, 6 February 2026
#  Revision:  761
#
#  License:   Copyright (c) 2026, John Warnes
# ===========================================================================

# Required Python3 and Pip3

import argparse
import configparser
import datetime
import os
import platform
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any, Dict, Optional

from packaging.version import parse as parse_version

SYS_DATA: dict[str, Any | dict[str, Any]] = {"version": {}}
SETTINGS: dict[str, Any] = {
    # DotSetup Script Version
    "version": "4.0.1",
    # Directories
    "dotfiles": "~/dotfiles",
    "backup_path": "~/dotfiles/backup",
    # Recommended Versions
    "recommended": {
        "vim": "8.0",
        "nvim": "0.7.0",
        "tmux": "3.0",
        "ssh": "9.6",  # 9.6p1
        "gpg": "2.4.4",
        "shell": "5.2.1",  # 5.2.21(1)-release
    },
}


class Colors:
    # Regular colors
    BLACK = "\033[30m"
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    MAGENTA = "\033[35m"
    CYAN = "\033[36m"
    WHITE = "\033[37m"

    # Bright colors
    BRIGHT_BLACK = "\033[90m"
    BRIGHT_RED = "\033[91m"
    BRIGHT_GREEN = "\033[92m"
    BRIGHT_YELLOW = "\033[93m"
    BRIGHT_BLUE = "\033[94m"
    BRIGHT_MAGENTA = "\033[95m"
    BRIGHT_CYAN = "\033[96m"
    BRIGHT_WHITE = "\033[97m"

    # Styles
    BOLD = "\033[1m"
    DIM = "\033[2m"
    ITALIC = "\033[3m"
    UNDERLINE = "\033[4m"
    BLINK = "\033[5m"
    REVERSE = "\033[7m"
    HIDDEN = "\033[8m"
    STRIKETHROUGH = "\033[9m"

    # Reset
    RESET = "\033[0m"


def strip_color_codes(text: str) -> str:
    """
    Remove all ANSI escape codes (color/style codes) from a string.
    """
    ansi_escape = re.compile(r"\033\[[0-9;]*m")
    return ansi_escape.sub("", text)


def box_draw(
    text: str,
    title: str = "",
    width: int = 0,
    align: str = "<",
    l_pad: int = 1,
    r_pad: int = 1,
    pad: str = " ",
) -> None:
    """
    Draw a fancy box around text with optional title and section dividers.

    Args:
        text: Content to display. Use \n for multiple lines.
              Prefix a line with '\x01 ' to create a section divider.
        title: Optional title displayed in the top border
        width: Minimum width (auto-calculated if 0)
        align: Text alignment: '<' (left), '^' (center), '>' (right)
        l_pad: Left padding inside box (spaces)
        r_pad: Right padding inside box (spaces)
        pad: Padding character (default space)

    Example:
        box_draw("Hello\nWorld", title="Greeting", align="^")
        box_draw("Data\n\x01 Section\nMore data")  # Creates divider
    """
    texts = text.split("\n") if "\n" in text else [text]

    if title:
        title = f"{pad}{title}{pad}"

    # Calculate the maximum width needed
    width = max(len(strip_color_codes(t)) for t in texts) if texts else width
    width = max(width, len(title))

    # Top border with optional title
    print(f"╔═{title}{'═' * (width - len(title))}═╗")

    # Content lines with optional section dividers
    for t in texts:
        if t and t[0] == "\x01":  # Section divider
            section_text = t[2:]
            if len(section_text) > 0:
                print(f"╠═{pad}{section_text}{pad}{'═' * (width - len(section_text) - 1)}╣")
            else:
                print(f"╠═{'═' * width}═╣")
        else:
            color_len = len(t)
            strip_len = len(strip_color_codes(t))
            color_extra = color_len - strip_len
            print(f"║{pad * l_pad}{t:{align}{width + color_extra}}{pad * r_pad}║")

    # Bottom border
    print(f"╚═{'═' * width}═╝")


def get_script_path() -> str:
    return os.path.dirname(os.path.realpath(sys.argv[0]))


def backup_file(file_path: str, backup_dir: Path) -> bool:
    """
    Backup a file or directory to the backup session directory before modifying it.
    Returns True if backup was created, False otherwise.
    """
    source = Path(file_path).expanduser()
    if not source.exists():
        return False

    # Use the original filename in the backup directory
    backup_path = backup_dir / source.name

    try:
        if source.is_dir():
            shutil.copytree(source, backup_path)
            print(f" Backed up directory: {source} -> {backup_path}")
        else:
            shutil.copy2(source, backup_path)
            print(f" Backed up file: {source} -> {backup_path}")
        return True
    except Exception as e:
        print(f" Warning: Failed to backup {source}: {e}")
        return False


def collect_system_data():
    """
    Used to collect current system state
    """
    SYS_DATA["home"] = os.path.expanduser("~")
    SYS_DATA["nvim_config"] = os.environ.get("XDG_CONFIG_HOME", SYS_DATA["home"] + "/.config")
    SYS_DATA["script_dir"] = get_script_path()
    SYS_DATA["script_file"] = str(__file__).split("/")[-1]
    SYS_DATA["os_kind"] = platform.system()  # Linux, Darwin, Windows
    SYS_DATA["os_release"] = platform.release()

    # Get OS-specific information
    if SYS_DATA["os_kind"] == "Linux":
        try:
            # Read /etc/os-release file (standard on most modern Linux distros)
            with open("/etc/os-release") as f:
                os_release_data = {}
                for line in f:
                    if "=" in line:
                        key, value = line.strip().split("=", 1)
                        # Remove quotes from value
                        os_release_data[key] = value.strip('"')

                SYS_DATA["os_name"] = os_release_data.get("NAME", "Linux")
                SYS_DATA["os_version"] = os_release_data.get("VERSION_ID", platform.release())
                SYS_DATA["os_codename"] = os_release_data.get(
                    "VERSION_CODENAME", os_release_data.get("CODENAME", None)
                )
        except (FileNotFoundError, PermissionError):
            SYS_DATA["os_name"] = "Linux"
            SYS_DATA["os_version"] = platform.release()
            SYS_DATA["os_codename"] = None

    elif SYS_DATA["os_kind"] == "Darwin":
        # macOS
        mac_ver = platform.mac_ver()[0]  # e.g., '12.6.0' or '13.0.1'
        SYS_DATA["os_version"] = mac_ver

        # Map macOS version to name
        try:
            major_version = int(mac_ver.split(".")[0])
            macos_names = {
                15: "Sequoia",
                14: "Sonoma",
                13: "Ventura",
                12: "Monterey",
                11: "Big Sur",
                10: "Catalina",  # 10.15
            }
            # For macOS 10.x versions, check minor version
            if major_version == 10:
                minor = int(mac_ver.split(".")[1]) if len(mac_ver.split(".")) > 1 else 0
                if minor >= 15:
                    version_name = "Catalina"
                elif minor == 14:
                    version_name = "Mojave"
                elif minor == 13:
                    version_name = "High Sierra"
                elif minor == 12:
                    version_name = "Sierra"
                else:
                    version_name = f"10.{minor}"
            else:
                version_name = macos_names.get(major_version, "macOS")

            SYS_DATA["os_name"] = f"macOS {version_name}"
        except (ValueError, IndexError):
            SYS_DATA["os_name"] = "macOS"

        SYS_DATA["os_codename"] = None

    elif SYS_DATA["os_kind"] == "Windows":
        # Windows
        win_ver = platform.win32_ver()
        release, version, csd, ptype = win_ver
        SYS_DATA["os_version"] = version  # e.g., '10.0.19041'

        # Map Windows version to name
        try:
            version_parts = version.split(".")
            major = int(version_parts[0])
            build = int(version_parts[2]) if len(version_parts) > 2 else 0

            if major == 10 and build >= 22000:
                os_name = "Windows 11"
            elif major == 10:
                os_name = "Windows 10"
            elif release == "8.1":
                os_name = "Windows 8.1"
            elif release == "8":
                os_name = "Windows 8"
            elif release == "7":
                os_name = "Windows 7"
            else:
                os_name = f"Windows {release}"

            SYS_DATA["os_name"] = os_name
        except (ValueError, IndexError):
            SYS_DATA["os_name"] = f"Windows {release}" if release else "Windows"

        SYS_DATA["os_codename"] = csd if csd else None  # Service pack info

    else:
        # Unknown/Other OS
        SYS_DATA["os_name"] = SYS_DATA["os_kind"]
        SYS_DATA["os_version"] = platform.release()
        SYS_DATA["os_codename"] = None

    # Get current shell
    shell_path = os.environ.get("SHELL", "")
    if shell_path:
        SYS_DATA['shell'] = shell_path.split("/")[-1] if shell_path else None
    else:
        try:
            # Get parent process (the shell that launched this script)
            ppid = os.getppid()
            SYS_DATA['shell'] = subprocess.check_output(
                f"ps -p {ppid} -o comm=", shell=True
            ).decode("ascii").strip()
        except (subprocess.CalledProcessError, FileNotFoundError):
            SYS_DATA['shell'] = None

    # Get shell version
    try:
        if SYS_DATA["shell"] in ["bash", "zsh"]:
            version_output = (
                subprocess.check_output(f"{SYS_DATA['shell']} --version", shell=True).decode("ascii").strip()
            )
            # Extract version number from first line
            SYS_DATA["version"]["shell"] = (
                version_output.split("\n")[0].split()[3] if SYS_DATA["shell"] == "bash" else version_output.split()[1]
            )
        else:
            SYS_DATA["version"]["shell"] = None
    except (subprocess.CalledProcessError, FileNotFoundError, IndexError):
        SYS_DATA["version"]["shell"] = None

    # Vim version
    try:
        SYS_DATA["version"]["vim"] = (
            subprocess.check_output("vim --version | head -1 | cut -d ' ' -f 5", shell=True).decode("ascii").strip()
            or None
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        SYS_DATA["version"]["vim"] = None

    # Neovim version
    try:
        SYS_DATA["version"]["nvim"] = (
            subprocess.check_output("nvim --version | head -1 | cut -d ' ' -f 2", shell=True)
            .decode("ascii")
            .strip()[1:]
            or None
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        SYS_DATA["version"]["nvim"] = None

    # tmux version
    try:
        SYS_DATA["version"]["tmux"] = (
            subprocess.check_output("tmux -V | cut -d ' ' -f 2", shell=True).decode("ascii").strip() or None
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        SYS_DATA["version"]["tmux"] = None

    # SSH version
    try:
        ssh_output = subprocess.check_output("ssh -V 2>&1 | head -1", shell=True).decode("ascii").strip()
        # SSH version is like "OpenSSH_8.2p1 Ubuntu-4ubuntu0.5, OpenSSL 1.1.1f  31 Mar 2020"
        SYS_DATA["version"]["ssh"] = ssh_output.split()[0].replace("OpenSSH_", "").split(",")[0]
    except (subprocess.CalledProcessError, FileNotFoundError, IndexError):
        SYS_DATA["version"]["ssh"] = None

    # GPG version
    try:
        SYS_DATA["version"]["gpg"] = (
            subprocess.check_output("gpg --version | head -1 | cut -d ' ' -f 3", shell=True).decode("ascii").strip()
            or None
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        SYS_DATA["version"]["gpg"] = None


def display_system_data(skipUser: bool = False):
    """
    Display current system information
    """

    # Build OS info display with optional codename
    os_info = f"Type   :  {SYS_DATA['os_kind']}\n"
    os_info += f"OS     :  {SYS_DATA['os_name']} {SYS_DATA['os_version']}"
    if SYS_DATA.get("os_codename"):
        os_info += f" ({SYS_DATA['os_codename']})\n"
    if SYS_DATA.get("os_release"):
        os_info += f"Release:  {SYS_DATA['os_release']}\n"

    def version_line(name, version, recommended, v_pad: int = 0, r_pad: int | None = 0) -> str:
        current = False
        if version:
            version = version.split("p")[0].split("-")[0].split("(")[0]
            current = parse_version(version) >= parse_version(recommended)
        else:
            version = "Not detected"
        if current:
            return f"{Colors.GREEN}✓{Colors.RESET} {name}:  {version:{v_pad}}"
        else:
            return (
                f"{Colors.RED}✗{Colors.RESET} {name}:  {version:{v_pad}}"
                f"{Colors.YELLOW} ! Expected >= {recommended:{r_pad}}{Colors.RESET}"
            )

    box_draw(
        os_info + f"\x01 DotSetup.py\n"
        f"Version  :  {SETTINGS['version']}\n"
        f"File     :  {SYS_DATA['script_file']}\n"
        f"Directory:  {SYS_DATA['script_dir']}\n"
        f"\x01 LOCATIONS\n"
        f"Home    :  {SYS_DATA['home']}\n"
        f"Dotfiles:  {SETTINGS['dotfiles']}\n"
        f"Backup  :  {SETTINGS['backup_path']}\n"
        f"\x01 VERSIONS\n"
        f"Shell Name:  {SYS_DATA['shell']}\n"
        + version_line(
            "shell   ",
            SYS_DATA["version"]["shell"],
            SETTINGS["recommended"]["shell"],
            v_pad=6,
        )
        + "\n"
        + version_line(
            "Vim     ",
            SYS_DATA["version"]["vim"],
            SETTINGS["recommended"]["vim"],
            v_pad=6,
        )
        + "\n"
        + version_line(
            "NeoVim  ",
            SYS_DATA["version"]["nvim"],
            SETTINGS["recommended"]["nvim"],
            v_pad=6,
        )
        + "\n"
        + version_line(
            "Tmux    ",
            SYS_DATA["version"]["tmux"],
            SETTINGS["recommended"]["tmux"],
            v_pad=6,
        )
        + "\n"
        + version_line(
            "SSH     ",
            SYS_DATA["version"]["ssh"],
            SETTINGS["recommended"]["ssh"],
            v_pad=6,
        )
        + "\n"
        + version_line(
            "GPG     ",
            SYS_DATA["version"]["gpg"],
            SETTINGS["recommended"]["gpg"],
            v_pad=6,
        )
        + "",
        title="OS",
    )


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

        if user["company"]:
            user["email"] = input(
                "Email '{}{}@{}.net [Enter] for default': ".format(
                    first.lower(), last[0].lower(), flat_string(user["company"])
                )
            )
            if user["email"] == "":
                user["email"] = "{}{}@{}.net".format(first.lower(), last[0].lower(), flat_string(user["company"]))
        else:
            user["email"] = input("Email: ")

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
            [
                "git",
                "clone",
                "--depth=1",
                "https://github.com/k-takata/minpac.git",
                str(minpac_dir),
            ],
            check=True,
            capture_output=True,
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

        # Read existing file content
        with open(fileName) as readFile:
            existing_lines = readFile.readlines()

        # Track which lines need to be added and in what order
        lines_to_add = []
        dotfiles_line = exportLines[0]  # export DOT_FILES=...
        clicolor_line = exportLines[1]  # export CLICOLOR=1
        autorun_line = exportLines[2]  # source $DOT_FILES/shell/autorun.sh

        # Check for existing DOT_FILES, CLICOLOR, and autorun lines
        has_dotfiles = False
        has_clicolor = False
        has_autorun = False
        dotfiles_correct = False

        for line in existing_lines:
            if line.startswith("export DOT_FILES="):
                has_dotfiles = True
                if line == dotfiles_line:
                    dotfiles_correct = True
                    print(f" DOT_FILES already set correctly: {line.strip()}")
                else:
                    print(f" Updating DOT_FILES from {line.strip()} to {dotfiles_line.strip()}")
            elif line == clicolor_line:
                has_clicolor = True
                print(f" Skip line (already exists): {line.strip()}")
            elif line == autorun_line:
                has_autorun = True
                print(f" Skip line (already exists): {line.strip()}")

        # Determine what needs to be added/updated
        if not has_dotfiles or not dotfiles_correct:
            lines_to_add.append(dotfiles_line)
        if not has_clicolor:
            lines_to_add.append(clicolor_line)
        if not has_autorun:
            lines_to_add.append(autorun_line)

        # If DOT_FILES path changed, we need to update the file
        if has_dotfiles and not dotfiles_correct:
            # Remove old DOT_FILES line and add new one in correct position
            with open(fileName, "w") as writeFile:
                for line in existing_lines:
                    if not line.startswith("export DOT_FILES="):
                        writeFile.write(line)
            # Now append the new lines in order
            with open(fileName, "a") as appendFile:
                for exportLine in lines_to_add:
                    print(f" Add line: {exportLine.strip()}")
                    appendFile.write(exportLine)
        elif lines_to_add:
            # Just append missing lines
            with open(fileName, "a") as appendFile:
                for exportLine in lines_to_add:
                    print(f" Add line: {exportLine.strip()}")
                    appendFile.write(exportLine)

    print("\nExporting DOT_FILES environment variable")
    exportLines = [
        f"export DOT_FILES={SYS_DATA['script_dir']}\n",
        "export CLICOLOR=1\n",
        "source $DOT_FILES/shell/autorun.sh\n",
    ]

    if SYS_DATA["os_kind"] == "Darwin":
        print(" Darwin detected: Appending files '~/.bash_profile' and '~/.zshrc'")

        # ~/.bash_profile
        safe_append(f"{SYS_DATA['home']}/.bash_profile", exportLines)

        # ~/.zshrc with zsh-specific prompt
        safe_append(
            f"{SYS_DATA['home']}/.zshrc",
            [*exportLines, "prompt='%F{028}%n@%m %F{025}%~%f %% '"],
        )
    else:
        # Linux and other systems: support both bash and zsh
        print(" Appending to '~/.bashrc' and '~/.zshrc'")

        # ~/.bashrc for bash (if it exists)
        bashrc_path = f"{SYS_DATA['home']}/.bashrc"
        if os.path.isfile(bashrc_path):
            safe_append(bashrc_path, exportLines)

        # ~/.zshrc for zsh (if it exists or user uses zsh)
        zshrc_path = f"{SYS_DATA['home']}/.zshrc"
        if os.path.isfile(zshrc_path) or os.path.islink(zshrc_path) or os.environ.get("SHELL", "").endswith("zsh"):
            safe_append(zshrc_path, exportLines)


def backup_all() -> None:
    """
    Create a backup of all dotfiles and system configurations without making any changes
    """
    # Create timestamped backup directory
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_base = Path(SETTINGS["backup_path"]).expanduser()
    backup_dir = backup_base / timestamp
    backup_dir.mkdir(parents=True, exist_ok=True)

    print()
    box_draw("Creating Backup")
    print(f"\nBackup directory: {backup_dir}\n")

    home = SYS_DATA["home"]
    dot_files = SYS_DATA["script_dir"]

    # List of files and directories to backup
    files_to_backup = [
        # Dotfiles directory configs
        f"{dot_files}/vim/user.vim",
        f"{dot_files}/git/gitconfig",
        # Home directory configs
        f"{home}/.vim",
        f"{home}/.vimrc",
        f"{home}/.tmux.conf",
        f"{home}/.gitconfig",
        f"{home}/.config/nvim/init.vim",
        # Shell RC files
        f"{home}/.bashrc",
        f"{home}/.bash_profile",
        f"{home}/.zshrc",
    ]

    backed_up_count = 0
    for file_path in files_to_backup:
        if os.path.exists(file_path) or os.path.islink(file_path):
            if backup_file(file_path, backup_dir):
                backed_up_count += 1

    print(f"\nBackup complete! {backed_up_count} file(s)/directory(ies) backed up.")
    print(f"Backup location: {backup_dir}\n")


def list_backups() -> list:
    """
    List all available backups sorted by timestamp (oldest first).
    Returns list of backup directory paths.
    """
    backup_base = Path(SETTINGS["backup_path"]).expanduser()
    if not backup_base.exists():
        return []

    # Get all directories that match timestamp format YYYYMMDD_HHMMSS
    backups = [d for d in backup_base.iterdir() if d.is_dir() and d.name.replace("_", "").isdigit()]
    # Sort by name (which is timestamp) - oldest first
    backups.sort()
    return backups


def display_backups() -> None:
    """
    Display all available backups in a human-readable format.
    """
    backups = list_backups()

    if not backups:
        print("\nNo backups found.")
        print(f"Backup directory: {Path(SETTINGS['backup_path']).expanduser()}\n")
        return

    data = []
    for i, backup_dir in enumerate(backups, 1):
        timestamp = backup_dir.name
        # Parse timestamp for human-readable format
        try:
            dt = datetime.datetime.strptime(timestamp, "%Y%m%d_%H%M%S")
            formatted = dt.strftime("%B %d, %Y at %I:%M:%S %p")
        except ValueError:
            formatted = timestamp

        # Count files in backup
        file_count = sum(1 for _ in backup_dir.iterdir())
        data.append([i, formatted, file_count, backup_dir])
        # print(f" {i}. {formatted} ({file_count} items)")
        # print(f"    Path: {backup_dir}")

    # print(f"{data=}")
    box_draw(
        f"Backup directory: {Path(SETTINGS['backup_path']).expanduser()}\n"
        "\x01 AVAILABLE\n" + "\n".join(f"{d[0]}: {d[1]} ({d[2]} items)" for d in data) + "\n\x01 \n"
        f"Total backups: {len(backups)}",
        title="BACKUPS",
    )

    print(f"To restore a backup, use: --restore <number>\n")


def restore(backup_index: Optional[int] = None) -> None:
    """
    Restore files from a backup.

    Args:
        backup_index: Which backup to restore (1=oldest, 2=second oldest, etc.)
                     If None, auto-restore single backup or list all backups.
    """
    backups = list_backups()

    if not backups:
        print("\nNo backups found.")
        print(f"Directory: {Path(SETTINGS['backup_path']).expanduser()}\n")
        return

    # If no index specified
    if backup_index is None:
        if len(backups) == 1:
            # Auto-restore the only backup
            backup_index = 1
            print(f"\nFound 1 backup. Auto-restoring...\n")
        else:
            # List all backups
            display_backups()
            return

    # Validate index
    if backup_index < 1 or backup_index > len(backups):
        print(f"\nError: Invalid backup index {backup_index}.")
        print(f"Available backups: 1 to {len(backups)}\n")
        return

    # Get the selected backup (1-indexed)
    backup_dir = backups[backup_index - 1]

    # Create a backup of current state before restoring
    print("\nCreating backup of current state before restoring...")
    backup_all()

    print()
    box_draw("Restoring Backup", title="Restore")
    print(f"\nRestoring from: {backup_dir}\n")

    home = SYS_DATA["home"]
    dot_files = SYS_DATA["script_dir"]

    # Map backup filenames to their original locations
    restore_map = {
        "user.vim": f"{dot_files}/vim/user.vim",
        "gitconfig": f"{dot_files}/git/gitconfig",
        ".vim": f"{home}/.vim",
        ".vimrc": f"{home}/.vimrc",
        ".tmux.conf": f"{home}/.tmux.conf",
        ".gitconfig": f"{home}/.gitconfig",
        "init.vim": f"{home}/.config/nvim/init.vim",
        ".bashrc": f"{home}/.bashrc",
        ".bash_profile": f"{home}/.bash_profile",
        ".zshrc": f"{home}/.zshrc",
    }

    restored_count = 0
    for backup_name, dest_path in restore_map.items():
        backup_file_path = backup_dir / backup_name
        if not backup_file_path.exists():
            continue

        dest = Path(dest_path)

        # Remove existing file/link/directory at destination
        if dest.exists() or dest.is_symlink():
            if dest.is_symlink():
                dest.unlink()
            elif dest.is_dir():
                shutil.rmtree(dest)
            else:
                dest.unlink()

        # Restore from backup
        try:
            if backup_file_path.is_dir():
                shutil.copytree(backup_file_path, dest)
                print(f" Restored directory: {dest}")
            else:
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(backup_file_path, dest)
                print(f" Restored file: {dest}")
            restored_count += 1
        except Exception as e:
            print(f" Warning: Failed to restore {dest}: {e}")

    print(f"\nRestore complete! {restored_count} file(s)/directory(ies) restored.\n")


def install(skipUser: bool = False):
    # Create complete backup before making any changes
    backup_all()

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
    xorgroup.add_argument(
        "-b",
        "--backup",
        help="Backup current configuration without making changes",
        action="store_true",
        default=False,
    )
    xorgroup.add_argument(
        "--backup-list",
        help="List all available backups",
        action="store_true",
        default=False,
    )
    xorgroup.add_argument(
        "--restore",
        help="Restore from backup (use --restore <number> to select specific backup)",
        nargs="?",
        type=int,
        const=0,
        metavar="N",
    )
    xorgroup.add_argument(
        "-s",
        "--status",
        help="Display system information and versions",
        action="store_true",
        default=False,
    )

    # parser.add_argument('-', help="Column to show", type=int, default=16, dest="col")
    parser.add_argument(
        "--skip-user",
        help="Install, Skipping user setup",
        action="store_true",
        default=False,
        dest="skipUser",
    )

    # Parse the given args
    args = parser.parse_args()

    # If no arguments provided, display help
    if not (
        args.install
        or args.skipUser
        or args.backup
        or args.backup_list
        or args.restore is not None
        or args.remove
        or args.status
    ):
        parser.print_help()
        sys.exit(0)

    collect_system_data()

    if args.status:
        display_system_data()

    elif args.install or args.skipUser:
        display_system_data(skipUser=args.skipUser)
        install(skipUser=args.skipUser)

    elif args.backup:
        backup_all()

    elif args.backup_list:
        display_backups()

    elif args.restore is not None:
        # args.restore is 0 if --restore with no argument, or the number if provided
        restore(args.restore if args.restore > 0 else None)


if __name__ == "__main__":
    main()
    sys.exit(0)  # Normal
