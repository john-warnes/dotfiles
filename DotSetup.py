#!/usr/bin/env python3

# =rev=======================================================================
#  File:      DotSetup.py
#  Brief:     Install Dot files
#  Version:   4.0.4
#
#  Author:    John Warnes
#  Created:   2018 January 04, Thursday
#
#  Modified:  Friday, 6 February 2026
#  Revision:  769
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
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional, Union

from packaging.version import parse as parse_version


@dataclass
class UserData:
    name: str
    user: str
    company: str
    email: str
    vim: str


@dataclass
class SystemData:
    home: Path
    nvim_config: Path
    script_dir: Path
    script_file: str
    os_kind: str
    os_release: str
    arch: str
    os_name: str
    os_version: str
    os_codename: Optional[str]
    shell: Optional[str]
    version: Dict[str, Optional[str]] = field(
        default_factory=lambda: {"shell": None, "vim": None, "nvim": None, "tmux": None, "ssh": None, "gpg": None}
    )


SYSTEM: SystemData = SystemData(
    home=Path.home(),
    nvim_config=Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))),
    script_dir=Path(os.path.realpath(sys.argv[0])).parent,
    script_file=Path(__file__).name,
    os_kind=platform.system(),
    os_release=platform.release(),
    arch=platform.machine(),
    os_name="",
    os_version="",
    os_codename=None,
    shell=None,
)


SETTINGS: Dict[str, Any] = {
    # DotSetup Script Version
    "version": "4.0.4",
    # Directories
    "dotfiles": "~/dotfiles",
    # Note: backup_path will be set dynamically in collect_system_data() to use script_dir
    "backup_path": None,
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
    text: Union[str, List[str]],
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
        text: Content to display. Can be:
              - A string with newlines: "Line1\\nLine2"
              - A list of strings: ["Line1", "Line2"]
              Prefix a line with '\\x01 ' to create a section divider.
        title: Optional title displayed in the top border
        width: Minimum width (auto-calculated if 0)
        align: Text alignment: '<' (left), '^' (center), '>' (right)
        l_pad: Left padding inside box (spaces)
        r_pad: Right padding inside box (spaces)
        pad: Padding character (default space)

    Example:
        box_draw("Hello\\nWorld", title="Greeting", align="^")
        box_draw(["Hello", "World"], title="Greeting", align="^")
        box_draw("Data\\n\\x01 Section\\nMore data")  # Creates divider
    """
    # Normalize input to list of strings
    if isinstance(text, str):
        texts = text.split("\n") if "\n" in text else [text]
    else:
        texts = list(text)

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


def get_script_path() -> Path:
    return Path(os.path.realpath(sys.argv[0])).parent


def safe_symlink(src: Union[str, Path], dest: Union[str, Path]) -> None:
    """
    Safely create a symlink, removing any existing file/directory/link at destination.

    Args:
        src: Source path for the symlink
        dest: Destination path where symlink will be created
    """
    dest_path = Path(dest).expanduser()
    src_path = Path(src).expanduser()

    # Remove existing destination
    if dest_path.is_symlink():
        dest_path.unlink()
    elif dest_path.is_file():
        dest_path.unlink()
    elif dest_path.is_dir():
        shutil.rmtree(dest_path)

    # Create symlink
    dest_path.parent.mkdir(parents=True, exist_ok=True)
    dest_path.symlink_to(src_path)


def backup_file(file_path: Union[str, Path], backup_dir: Path) -> bool:
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


def collect_system_data() -> None:
    """
    Collect and populate system information into SYS_DATA global.

    Detects OS (Linux/macOS/Windows), architecture, shell type/version,
    and installed tool versions (vim, nvim, tmux, ssh, gpg).
    """
    global SYSTEM
    home = Path.home()
    nvim_config = Path(os.environ.get("XDG_CONFIG_HOME", str(home / ".config")))
    script_dir = get_script_path()
    script_file = Path(__file__).name
    os_kind = platform.system()  # Linux, Darwin, Windows
    os_release = platform.release()
    arch = platform.machine()  # x86_64, i686, armv7l, aarch64, etc.

    # Get OS-specific information
    if os_kind == "Linux":
        try:
            # Read /etc/os-release file (standard on most modern Linux distros)
            with open("/etc/os-release") as f:
                os_release_data = {}
                for line in f:
                    if "=" in line:
                        key, value = line.strip().split("=", 1)
                        # Remove quotes from value
                        os_release_data[key] = value.strip('"')

                os_name = os_release_data.get("NAME", "Linux")
                os_version = os_release_data.get("VERSION_ID", platform.release())
                os_codename = os_release_data.get("VERSION_CODENAME", os_release_data.get("CODENAME", None))
        except (FileNotFoundError, PermissionError):
            os_name = "Linux"
            os_version = platform.release()
            os_codename = None

    elif os_kind == "Darwin":
        # macOS
        mac_ver = platform.mac_ver()[0]  # e.g., '12.6.0' or '13.0.1'
        os_version = mac_ver
        os_name = "macOS"
        os_codename = None

    elif os_kind == "Windows":
        # Windows
        win_ver = platform.win32_ver()
        release, version, csd, _ = win_ver
        os_version = version  # e.g., '10.0.19041'

        # Distinguish Windows 11 from Windows 10 by build number
        try:
            version_parts = version.split(".")
            major = int(version_parts[0])
            build = int(version_parts[2]) if len(version_parts) > 2 else 0

            if major == 10 and build >= 22000:
                os_name = "Windows 11"
            else:
                os_name = f"Windows {release}" if release else "Windows"
        except (ValueError, IndexError):
            os_name = f"Windows {release}" if release else "Windows"
        os_codename = csd if csd else None  # Service pack info

    else:
        # Unknown/Other OS
        os_name = os_kind
        os_version = platform.release()
        os_codename = None

    # Initialize SystemData
    SYSTEM = SystemData(
        home=home,
        nvim_config=nvim_config,
        script_dir=script_dir,
        script_file=script_file,
        os_kind=os_kind,
        os_release=os_release,
        arch=arch,
        os_name=os_name,
        os_version=os_version,
        os_codename=os_codename,
        shell=None,
    )

    # Get current shell
    shell_path = os.environ.get("SHELL", "")
    if shell_path:
        SYSTEM.shell = shell_path.split("/")[-1] if shell_path else None
    else:
        try:
            # Get parent process (the shell that launched this script)
            ppid = os.getppid()
            SYSTEM.shell = subprocess.check_output(f"ps -p {ppid} -o comm=", shell=True).decode("ascii").strip()
        except (subprocess.CalledProcessError, FileNotFoundError):
            SYSTEM.shell = None

    # Get shell version
    try:
        if SYSTEM.shell in ["bash", "zsh"]:
            version_output = subprocess.check_output(f"{SYSTEM.shell} --version", shell=True).decode("ascii").strip()
            # Extract version number from first line
            SYSTEM.version["shell"] = (
                version_output.split("\n")[0].split()[3] if SYSTEM.shell == "bash" else version_output.split()[1]
            )
        else:
            SYSTEM.version["shell"] = None
    except (subprocess.CalledProcessError, FileNotFoundError, IndexError):
        SYSTEM.version["shell"] = None

    # Vim version
    try:
        SYSTEM.version["vim"] = (
            subprocess.check_output("vim --version | head -1 | cut -d ' ' -f 5", shell=True).decode("ascii").strip()
            or None
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        SYSTEM.version["vim"] = None

    # Neovim version
    try:
        SYSTEM.version["nvim"] = (
            subprocess.check_output("nvim --version | head -1 | cut -d ' ' -f 2", shell=True)
            .decode("ascii")
            .strip()[1:]
            or None
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        SYSTEM.version["nvim"] = None

    # tmux version
    try:
        SYSTEM.version["tmux"] = (
            subprocess.check_output("tmux -V | cut -d ' ' -f 2", shell=True).decode("ascii").strip() or None
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        SYSTEM.version["tmux"] = None

    # SSH version
    try:
        ssh_output = subprocess.check_output("ssh -V 2>&1 | head -1", shell=True).decode("ascii").strip()
        # SSH version is like "OpenSSH_8.2p1 Ubuntu-4ubuntu0.5, OpenSSL 1.1.1f  31 Mar 2020"
        SYSTEM.version["ssh"] = ssh_output.split()[0].replace("OpenSSH_", "").split(",")[0]
    except (subprocess.CalledProcessError, FileNotFoundError, IndexError):
        SYSTEM.version["ssh"] = None

    # GPG version
    try:
        SYSTEM.version["gpg"] = (
            subprocess.check_output("gpg --version | head -1 | cut -d ' ' -f 3", shell=True).decode("ascii").strip()
            or None
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        SYSTEM.version["gpg"] = None

    # Set backup path to script directory (not ~/dotfiles which may not exist yet)
    SETTINGS["backup_path"] = str(SYSTEM.script_dir / "backup")


def display_system_data() -> None:
    """
    Display current system information in a formatted box.

    Shows OS details, architecture, script version, installed tools,
    and version compliance checks against recommended versions.
    """

    # Build OS info display with optional codename
    if SYSTEM is None:
        return

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

    # Build lines as a list for cleaner code
    lines = [
        f"Type   :  {SYSTEM.os_kind}",
        f"Arch   :  {SYSTEM.arch}",
    ]

    # OS line with optional codename
    os_line = f"OS     :  {SYSTEM.os_name} {SYSTEM.os_version}"
    if SYSTEM.os_codename:
        os_line += f" ({SYSTEM.os_codename})"
    lines.append(os_line)

    if SYSTEM.os_release:
        lines.append(f"Release:  {SYSTEM.os_release}")

    # DotSetup.py section
    lines.extend([
        "\x01 DotSetup.py",
        f"Version  :  {SETTINGS['version']}",
        f"File     :  {SYSTEM.script_file}",
        f"Directory:  {str(SYSTEM.script_dir)}",
    ])

    # Locations section
    lines.extend([
        "\x01 LOCATIONS",
        f"Home    :  {str(SYSTEM.home)}",
        f"Dotfiles:  {SETTINGS['dotfiles']}",
        f"Backup  :  {SETTINGS['backup_path']}",
    ])

    # Versions section
    lines.extend([
        "\x01 VERSIONS",
        f"Shell Name:  {SYSTEM.shell}",
        version_line("shell   ", SYSTEM.version["shell"], SETTINGS["recommended"]["shell"], v_pad=6),
        version_line("Vim     ", SYSTEM.version["vim"], SETTINGS["recommended"]["vim"], v_pad=6),
        version_line("NeoVim  ", SYSTEM.version["nvim"], SETTINGS["recommended"]["nvim"], v_pad=6),
        version_line("Tmux    ", SYSTEM.version["tmux"], SETTINGS["recommended"]["tmux"], v_pad=6),
        version_line("SSH     ", SYSTEM.version["ssh"], SETTINGS["recommended"]["ssh"], v_pad=6),
        version_line("GPG     ", SYSTEM.version["gpg"], SETTINGS["recommended"]["gpg"], v_pad=6),
    ])

    box_draw(lines, title="OS")


def flat_string(text: str) -> str:
    """
    Convert string to lowercase and remove all spaces.

    Used for generating email domains from company names.
    Example: "Example Corp" -> "examplecorp"
    """
    text = text.replace(" ", "")
    text = text.lower()
    return text


def ask_user_data() -> UserData:
    """
    Interactively collect user information for dotfiles configuration.

    Prompts for full name, username, company, email, and default editor.
    Provides intelligent defaults based on name/company inputs.

    Returns:
        Dictionary with keys: name, user, company, email, vim

    Raises:
        SystemExit: If user doesn't provide a valid name
    """
    user: Dict[str, str] = {}
    print()
    box_draw("User information")
    print()
    user["name"] = input("Full Name 'John Smith': ")
    if user["name"] == "":
        print("Error! Must enter a name. example: John Smith")
        sys.exit(1)

    # Parse name - handle single name or multiple names
    name_parts = user["name"].split()
    if len(name_parts) == 1:
        # Single name - use it as both first and last
        first = last = name_parts[0]
    else:
        # Multiple names - first and last
        first, *mid, last = name_parts

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

    user["vim"] = input("Default console editor '{}' [Enter] for default: ".format("[vim], nvim, nano, code"))
    if user["vim"] == "":
        user["vim"] = "vim"

    print("")
    return UserData(
        name=user["name"],
        user=user["user"],
        company=user["company"],
        email=user["email"],
        vim=user["vim"],
    )


def create_user_vim(user: Optional[UserData]) -> None:
    """
    Generate vim/user.vim with user-specific vim variables.

    Creates variables: g:_NAME_, g:_USER_, g:_COMPANY_, g:_EMAIL_, g:_VIM_
    These can be used in vim configuration for personalization.

    Args:
        user: User data dictionary, or None to skip creation
    """
    if not user:
        return
    print("Creating user.vim")

    vim_user_path = Path(f"{SETTINGS['dotfiles']}/vim/user.vim").expanduser()
    with open(vim_user_path, "w") as f:
        f.write(f"let g:_NAME_    = '{user.name}'\n")
        f.write(f"let g:_USER_    = '{user.user}'\n")
        f.write(f"let g:_COMPANY_ = '{user.company}'\n")
        f.write(f"let g:_EMAIL_   = '{user.email}'\n")
        f.write(f"let g:_VIM_     = '{user.vim}'\n")


def create_user_git(user: Optional[UserData]) -> None:
    """
    Create git/gitconfig with user information and standard configuration.

    Includes user name/email, aliases (s, logpretty, logshort),
    fast-forward-only pulls, and 8-hour credential caching.

    Args:
        user: User data dictionary with name, email, vim keys
    """
    print("Creating gitconfig")

    git_config_path = Path(f"{SETTINGS['dotfiles']}/git/gitconfig").expanduser()
    with open(git_config_path, "w", encoding="utf-8") as f:
        f.write(
            "\n".join(
                [
                    "[user]",
                    f"	name  = {user.name}" if user else "",
                    f"	email = {user.email}" if user else "",
                    "[core]",
                    f"	editor = {user.vim}" if user else "",
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


def link_user_git(user: Optional[UserData]) -> None:
    """
    Link or update ~/.gitconfig with dotfiles configuration.

    If ~/.gitconfig exists, updates it with user info and key settings.
    Otherwise, creates symlink to {dotfiles}/git/gitconfig.

    Args:
        user: User data dictionary, or None to skip user info updates
    """
    print("linking or editing users gitconfig")
    # Check if a config file already exists in the home folder, If it does
    # the file we created will not be linked so lets just edit the existing file
    config_file = (SYSTEM.home / ".gitconfig").expanduser()
    if config_file.is_file() or config_file.is_symlink():
        print("~/.gitconfig Already exists updating")
        config = configparser.ConfigParser()
        config.read(config_file)

        # Update user information if provided
        if user:
            if "user" in config:
                if "name" in config["user"]:
                    config["user"]["name"] = user.name
                if "email" in config["user"]:
                    config["user"]["email"] = user.email
            else:
                config["user"] = {"name": user.name, "email": user.email}

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
        # File does not exist, create symlink
        src = (SYSTEM.script_dir / "git" / "gitconfig").expanduser()
        dest = Path("~/.gitconfig").expanduser()
        safe_symlink(src, dest)


def create_folders() -> None:
    """
    Create required directories for dotfiles operation.

    Creates:
    - ~/.config/nvim/ for neovim configuration
    - ~/.ssh/controlmasters/ (mode 700) for SSH connection multiplexing
    """
    # Neovim config directory
    nvim_dir = (SYSTEM.home / ".config" / "nvim").expanduser()
    if not nvim_dir.exists():
        nvim_dir.mkdir(parents=True, exist_ok=True)
        print(f"Created {nvim_dir}")

    # SSH controlmasters directory for SSH connection multiplexing
    ssh_control_dir = (SYSTEM.home / ".ssh" / "controlmasters").expanduser()
    if not ssh_control_dir.exists():
        ssh_control_dir.mkdir(parents=True, exist_ok=True)
        ssh_control_dir.chmod(0o700)  # Secure permissions
        print(f"Created {ssh_control_dir} with mode 700")


def ensure_dotfiles_symlink() -> None:
    """
    Ensure ~/dotfiles symlink points to the actual script directory.
    
    If the script is running from a location other than ~/dotfiles,
    creates a symlink ~/dotfiles -> {actual_script_location}.
    This allows the dotfiles to be located anywhere while maintaining
    the expected ~/dotfiles path for exports and references.
    """
    dotfiles_path = (SYSTEM.home / "dotfiles").expanduser()
    script_dir = SYSTEM.script_dir.resolve()

    # If ~/dotfiles doesn't exist, create symlink
    if not dotfiles_path.exists():
        print(f"\nCreating symlink: ~/dotfiles -> {script_dir}")
        dotfiles_path.symlink_to(script_dir)
        return

    # If it's a symlink, check if it points to the right place
    if dotfiles_path.is_symlink():
        current_target = dotfiles_path.resolve()
        if current_target != script_dir:
            print(f"\nUpdating ~/dotfiles symlink")
            print(f"  Old target: {current_target}")
            print(f"  New target: {script_dir}")
            dotfiles_path.unlink()
            dotfiles_path.symlink_to(script_dir)
        else:
            print(f"\n~/dotfiles symlink already points to correct location")
        return

    # If it's a directory and matches script_dir, we're running from ~/dotfiles
    if dotfiles_path.is_dir():
        if dotfiles_path.resolve() == script_dir:
            print(f"\n~/dotfiles is already the script directory")
        else:
            print(f"\nWarning: ~/dotfiles exists as a directory but is not the script location")
            print(f"  Expected: {script_dir}")
            print(f"  Found:    {dotfiles_path.resolve()}")
            print(f"  Please manually resolve this conflict")
            sys.exit(1)


def configure_ssh_multiplexing() -> None:
    """
    Configure SSH connection multiplexing in ~/.ssh/config.

    Adds ControlMaster, ControlPath, and ControlPersist settings if not already present.
    Creates ~/.ssh/config if it doesn't exist.
    """
    ssh_config_path = (SYSTEM.home / ".ssh" / "config").expanduser()

    # Ensure .ssh directory exists with proper permissions
    ssh_dir = ssh_config_path.parent
    if not ssh_dir.exists():
        ssh_dir.mkdir(mode=0o700, parents=True)
        print(f"Created {ssh_dir} with mode 700")

    # Configuration lines to add
    config_lines = [
        "# SSH Connection Multiplexing (added by DotSetup.py)\n",
        "ControlMaster auto\n",
        "ControlPath ~/.ssh/controlmasters/%r@%h:%p\n",
        "ControlPersist 10m\n",
        "\n",
    ]

    # Create file if it doesn't exist
    if not ssh_config_path.exists():
        print("Creating ~/.ssh/config with SSH multiplexing settings")
        with open(ssh_config_path, "w") as f:
            f.writelines(config_lines)
        ssh_config_path.chmod(0o600)  # Secure permissions
        return

    # Read existing config
    with open(ssh_config_path) as f:
        existing_content = f.read()

    # Check if multiplexing is already configured
    has_control_master = "ControlMaster" in existing_content
    has_control_path = "ControlPath" in existing_content
    has_control_persist = "ControlPersist" in existing_content

    if has_control_master and has_control_path and has_control_persist:
        print("SSH multiplexing already configured in ~/.ssh/config")
        return

    # Append missing configuration
    print("Adding SSH multiplexing settings to ~/.ssh/config")
    with open(ssh_config_path, "a") as f:
        # Add newline if file doesn't end with one
        if existing_content and not existing_content.endswith("\n"):
            f.write("\n")
        f.writelines(config_lines)

    print(" Added: ControlMaster auto")
    print(" Added: ControlPath ~/.ssh/controlmasters/%r@%h:%p")
    print(" Added: ControlPersist 10m")


def install_minpac() -> None:
    """
    Install minpac plugin manager if not already present
    """
    minpac_dir = (SYSTEM.script_dir / "vim" / "pack" / "minpac" / "opt" / "minpac").expanduser()

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
    Create symlinks from dotfiles to standard home directory locations.

    Removes any existing files/links/directories at destination before linking.
    Creates these symlinks:
    - {DOT_FILES}/vim -> ~/.vim
    - {DOT_FILES}/vim/vimrc -> ~/.vimrc
    - {DOT_FILES}/tmux/tmux.conf -> ~/.tmux.conf
    - {DOT_FILES}/git/gitconfig -> ~/.gitconfig
    - {DOT_FILES}/nvim/init.vim -> ~/.config/nvim/init.vim
    """
    home = SYSTEM.home
    dot_files = SYSTEM.script_dir
    symlinks = {
        dot_files / "vim": home / ".vim",
        dot_files / "vim" / "vimrc": home / ".vimrc",
        dot_files / "tmux" / "tmux.conf": home / ".tmux.conf",
        dot_files / "git" / "gitconfig": home / ".gitconfig",
        dot_files / "nvim" / "init.vim": home / ".config" / "nvim" / "init.vim",
    }
    print("\nCreating symlinks")

    for src, dest in symlinks.items():
        print(f" {str(src)} -> {str(dest)}")
        safe_symlink(src, dest)


def export_dot_files() -> None:
    """
    Export DOT_FILES environment variable to shell configuration files.

    Appends to ~/.bashrc, ~/.bash_profile, and/or ~/.zshrc depending on OS.
    Adds three lines:
    - export DOT_FILES={script_dir}
    - export CLICOLOR=1
    - source $DOT_FILES/shell/autorun.sh

    Safely handles existing lines to avoid duplicates, and updates
    DOT_FILES path if it has changed.
    """

    def safe_append(fileName: Union[str, Path], exportLines: List[str]) -> None:
        if not exportLines:
            # No lines to export
            return

        file_path = Path(fileName).expanduser()
        print(f"\n Processing: {file_path}")

        if not (file_path.is_file() or file_path.is_symlink()):
            with open(file_path, "a"):
                # Create file if does not exist
                pass

        # Read existing file content
        with open(file_path) as readFile:
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
                    print(f"   ✓ DOT_FILES already set correctly: {line.strip()}")
                else:
                    print(f"   → Updating DOT_FILES from {line.strip()} to {dotfiles_line.strip()}")
            elif line == clicolor_line:
                has_clicolor = True
                print(f"   ✓ Already exists: {line.strip()}")
            elif line == autorun_line:
                has_autorun = True
                print(f"   ✓ Already exists: {line.strip()}")

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
            with open(file_path, "w") as writeFile:
                for line in existing_lines:
                    if not line.startswith("export DOT_FILES="):
                        writeFile.write(line)
            # Now append the new lines in order
            with open(file_path, "a") as appendFile:
                for exportLine in lines_to_add:
                    print(f"   + Adding: {exportLine.strip()}")
                    appendFile.write(exportLine)
        elif lines_to_add:
            # Just append missing lines
            with open(file_path, "a") as appendFile:
                for exportLine in lines_to_add:
                    print(f"   + Adding: {exportLine.strip()}")
                    appendFile.write(exportLine)
        else:
            print(f"   ✓ All lines already present")

    print("\nExporting DOT_FILES environment variable")
    exportLines = [
        f"export DOT_FILES={str(SYSTEM.script_dir)}\n",
        "export CLICOLOR=1\n",
        "source $DOT_FILES/shell/autorun.sh\n",
    ]

    if SYSTEM.os_kind == "Darwin":
        print(" Darwin detected: Appending files '~/.bash_profile' and '~/.zshrc'")

        # ~/.bash_profile
        safe_append(SYSTEM.home / ".bash_profile", exportLines)

        # ~/.zshrc with zsh-specific prompt
        safe_append(
            SYSTEM.home / ".zshrc",
            [*exportLines, "prompt='%F{028}%n@%m %F{025}%~%f %% '"],
        )
    else:
        # Linux and other systems: support both bash and zsh
        print(" Appending to '~/.bashrc' and '~/.zshrc'")

        # ~/.bashrc for bash (if it exists)
        bashrc_path = SYSTEM.home / ".bashrc"
        if bashrc_path.is_file():
            safe_append(bashrc_path, exportLines)

        # ~/.zshrc for zsh (if it exists or user uses zsh)
        zshrc_path = SYSTEM.home / ".zshrc"
        if zshrc_path.is_file() or zshrc_path.is_symlink() or os.environ.get("SHELL", "").endswith("zsh"):
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

    home = SYSTEM.home
    dot_files = SYSTEM.script_dir

    # List of files and directories to backup
    files_to_backup = [
        # Dotfiles directory configs
        dot_files / "vim" / "user.vim",
        dot_files / "git" / "gitconfig",
        # Home directory configs
        home / ".vim",
        home / ".vimrc",
        home / ".tmux.conf",
        home / ".gitconfig",
        home / ".config" / "nvim" / "init.vim",
        # Shell RC files
        home / ".bashrc",
        home / ".bash_profile",
        home / ".zshrc",
    ]

    backed_up_count = 0
    for file_path in files_to_backup:
        fp = Path(file_path).expanduser()
        if fp.exists() or fp.is_symlink():
            if backup_file(fp, backup_dir):
                backed_up_count += 1

    print(f"\nBackup complete! {backed_up_count} file(s)/directory(ies) backed up.")
    print(f"Backup location: {backup_dir}\n")


def list_backups() -> list[Path]:
    """
    List all available backups sorted by timestamp (oldest first).

    Scans backup directory for subdirectories matching YYYYMMDD_HHMMSS format.

    Returns:
        List of Path objects for backup directories, sorted oldest to newest
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

    # Build lines as a list
    lines = [f"Backup directory: {Path(SETTINGS['backup_path']).expanduser()}"]

    # AVAILABLE section
    lines.append("\x01 AVAILABLE")
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
        lines.append(f"{i}: {formatted} ({file_count} items)")

    # Footer section
    lines.extend([
        "\x01 ",
        f"Total backups: {len(backups)}",
    ])

    box_draw(lines, title="BACKUPS")

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

    home = SYSTEM.home
    dot_files = SYSTEM.script_dir

    # Map backup filenames to their original locations
    restore_map = {
        "user.vim": dot_files / "vim" / "user.vim",
        "gitconfig": dot_files / "git" / "gitconfig",
        ".vim": home / ".vim",
        ".vimrc": home / ".vimrc",
        ".tmux.conf": home / ".tmux.conf",
        ".gitconfig": home / ".gitconfig",
        "init.vim": home / ".config" / "nvim" / "init.vim",
        ".bashrc": home / ".bashrc",
        ".bash_profile": home / ".bash_profile",
        ".zshrc": home / ".zshrc",
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


def install(skipUser: bool = False) -> None:
    """
    Execute the full dotfiles installation workflow.

    Steps:
    1. Ensure ~/dotfiles symlink is correctly set up
    2. Collect user information (unless skipUser=True)
    3. Create user-specific vim and git configs
    4. Backup existing configurations
    5. Link/update ~/.gitconfig
    6. Create required directories
    7. Configure SSH connection multiplexing
    8. Install minpac vim plugin manager
    9. Create symlinks to home directory
    10. Export DOT_FILES to shell configs

    Args:
        skipUser: If True, skip user data collection and use existing configs
    """
    # Ensure ~/dotfiles points to the script directory
    ensure_dotfiles_symlink()

    user = None
    if not skipUser:
        user = ask_user_data()

    create_user_vim(user)
    create_user_git(user)
    backup_all()  # Create complete backup before making any changes to external files
    link_user_git(user)
    create_folders()
    configure_ssh_multiplexing()
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


def main() -> None:
    """
    Main entry point for DotSetup.py script.

    Parses command-line arguments and dispatches to appropriate functions:
    - --install / --skip-user: Install dotfiles
    - --status: Display system information
    - --backup: Create backup of current configuration
    - --backup-list: List all available backups
    - --restore [N]: Restore from backup
    """
    # Processor for command line arguments
    parser = argparse.ArgumentParser()

    # Group
    xorgroup = parser.add_mutually_exclusive_group()
    xorgroup.add_argument("-i", "--install", help="Install Files", action="store_true", default=False)
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
        args.install or args.skipUser or args.backup or args.backup_list or args.restore is not None or args.status
    ):
        parser.print_help()
        sys.exit(0)

    collect_system_data()

    if args.status:
        display_system_data()

    elif args.install or args.skipUser:
        display_system_data()
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
