# Dotfiles

Personal configuration files for Linux and macOS development environments.

## Features

- **Vim/Neovim**: Full-featured configuration with plugin management
- **Tmux**: Enhanced terminal multiplexer with custom themes
- **Shell**: Bash/Zsh configuration with aliases and custom functions
- **Git**: Pre-configured with useful aliases and settings
- **Scripts**: Collection of utility scripts for daily tasks

## Quick Start

### Prerequisites

- Python 3.8 >
- Git
- Vim 8.0+ or Neovim 0.2.0+
- Tmux 3.0+ (recommended)

### Installation

Clone the repository and run the installation script:

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

Or with custom user information:

```bash
python3 DotSetup.py --install
```

### Post-Installation

1. **Install Vim plugins**: Open vim and run `:PackUpdate`
2. **Reload shell**: Close and reopen your terminal, or run `source ~/.bashrc` (or `~/.zshrc`)
3. **Verify setup**: Check that `$DOT_FILES` environment variable is set

## Project Structure

```
dotfiles/
├── DotSetup.py           # Main installation script
├── install.sh            # Quick install wrapper
├── git/
│   └── gitconfig         # Git configuration
├── nvim/
│   └── init.vim          # Neovim entry point
├── scripts/
│   ├── git-stats         # Git statistics tool
│   ├── parallel_commands # Run commands in parallel
│   └── ...               # Various utility scripts
├── shell/
│   ├── autorun.sh        # Shell initialization
│   ├── shell_aliases     # Common aliases
│   └── set_cursor.sh     # Terminal cursor configuration
├── tmux/
│   ├── tmux.conf         # Main tmux configuration
│   └── theme/            # Tmux color themes
└── vim/
    ├── vimrc             # Main Vim configuration
    ├── vim8/             # Vim 8-specific plugins
    ├── nvim/             # Neovim-specific plugins
    └── pack/             # Plugin directory (managed by minpac)
```

## Configuration Details

### Vim/Neovim

- **Plugin Manager**: [minpac](https://github.com/k-takata/minpac) (automatically installed)
- **Color Scheme**: [gruvbox](https://github.com/morhetz/gruvbox)
- **Key Plugins**:
  - jvim - Custom Vim enhancements
  - ALE - Asynchronous linting
  - tagbar - Code structure browser
  - vim-tmux-navigator - Seamless tmux/vim navigation

#### Plugin Management

Update all plugins:
```vim
:PackUpdate
```

Clean unused plugins:
```vim
:PackClean
```

### Tmux

- **Version Support**: Handles tmux 2.9+ and 3.0+ differences
- **Features**:
  - True color support
  - Custom status bar with prefix indicator
  - Mouse support
  - Vim-style pane navigation
  - Version-specific theme loading

#### Key Bindings

- **Prefix**: `Ctrl+a` (shown in status bar as `[^A]`)
- **Split Panes**: 
  - Horizontal: `prefix + |`
  - Vertical: `prefix + -`
- **Navigate Panes**: `Ctrl + Arrow Keys` (works with vim-tmux-navigator)
- **Reload Config**: `prefix + r`

### Shell (Bash/Zsh)

Configuration is automatically loaded via the `DOT_FILES` environment variable.

#### Key Features

- **Git integration**: Enhanced prompt with branch information
- **History management**: Large history with deduplication
- **Virtualenv support**: Automatic Python virtualenv detection
- **Color support**: Enhanced ls colors for macOS and Linux
- **Custom cursor**: Steady vertical bar in insert mode

#### Environment Variables

- `DOT_FILES`: Path to dotfiles directory
- `HISTSIZE`: 50000
- `SAVEHIST`: 100000 (zsh)

### Git

Pre-configured with:
- User name and email (set during installation)
- Useful aliases (`git s`, `git logpretty`, `git logshort`)
- 8-hour credential cache
- `main` as default branch
- Fast-forward only pulls

#### Git Aliases

- `git s` - Status shortcut
- `git logpretty` - Colored graph log with full decoration
- `git logshort` - Compact one-line log with graph
- `git stats-commits` - Show commit counts by author
- `git details` - Show last commit with full details
- `git export` - Create compressed tar archive

## Scripts

Utility scripts located in `scripts/`:

- **git-stats**: Generate detailed git statistics by author/committer
- **parallel_commands**: Execute commands in parallel with progress tracking
- **24-bit-color.sh**: Test terminal true color support
- **detectOS.sh**: Detect operating system and export OS variable
- **lock.sh / unlock.sh**: secure directory encryption utilities
- **manhtml.sh**: lookup html tags like man pages

Usage examples:

```bash
# Git statistics for last 30 days
git-stats

# Git statistics for specific author
git-stats --author "John" --days 60

# Run multiple commands in parallel
parallel_commands "make build" "npm test" "docker build ."
```

## Customization

### User-Specific Files

These files are created during installation and not tracked by git:

- `vim/user.vim` - Contains user information for vim templates
- `.gitignore` entries:
  - `vim/user.vim`
  - `vim/undo/`
  - `vim/view/`
  - `vim/pack/minpac/start/`
  - `vim/pack/minpac/opt/minpac/`

### Adding Custom Configuration

1. **Shell aliases**: Add to `shell/shell_aliases`
2. **Vim settings**: Add to `vim/user.vim` or `vim/vimrc`
3. **Tmux settings**: Add to `tmux/tmux.conf`
4. **Git aliases**: Edit `git/gitconfig`
5. **SSH hosts**: Add to `secure/ssh/config`

## SSH Configuration

SSH is configured for optimal color support and tmux compatibility.

### Features

- **Color Support**: Automatically sets `TERM=xterm-256color` and `COLORTERM=truecolor` over SSH
- **Tmux Compatible**: Proper terminal type detection for tmux sessions over SSH
- **Connection Multiplexing**: Reuses existing connections for faster subsequent SSH sessions
- **Keep-Alive**: Maintains connections with 60-second intervals
- **Environment Forwarding**: Passes `LANG`, `LC_*`, and `COLORTERM` to remote hosts

### SSH Configuration Location

`secure/ssh/config` is symlinked to `~/.ssh/config` during installation.

### Adding New SSH Hosts

Edit `secure/ssh/config`:

```ssh-config
Host myserver
  User my_user_name
  HostName example.com
  Port 22
  IdentityFile ~/.ssh/id_rsa
  IdentitiesOnly yes
```

### Tmux Over SSH

The configuration automatically detects SSH sessions and:
- Sets appropriate `TERM` variable
- Enables true color support
- Configures UTF-8 encoding

Simply SSH to your server and start tmux:
```bash
ssh myserver
tmux
```

Colors and terminal features will work correctly.

### Connection Multiplexing

SSH connections are multiplexed through `~/.ssh/controlmasters/`. This means:
- First connection establishes a master
- Subsequent connections reuse the master (instant login)
- Master persists for 10 minutes after last connection

## Troubleshooting

### Vim Plugins Not Loading

Run `:PackUpdate` in vim to install/update plugins. If minpac isn't found:

```bash
git clone --depth=1 https://github.com/k-takata/minpac.git ~/.vim/pack/minpac/opt/minpac
```

### Neovim PackUpdate Not Working

Neovim loads minpac differently. The configuration automatically handles this by directly sourcing the minpac autoload file.

### Tmux Colors Look Wrong

Ensure your terminal supports true color:
```bash
~/dotfiles/scripts/24-bit-color.sh
```

Add to `~/.bashrc` or `~/.zshrc`:
```bash
export COLORTERM=truecolor
```

### Shell Configuration Not Loading

Verify `DOT_FILES` environment variable:
```bash
echo $DOT_FILES
```

Should output: `/home/username/dotfiles`

If not set, source the autorun script:
```bash
export DOT_FILES=~/dotfiles
source $DOT_FILES/shell/autorun.sh
```

## Platform-Specific Notes

### macOS

- Uses `~/.bash_profile` and `~/.zshrc`
- GNU ls colors disabled (uses macOS `-G` flag)
- Some scripts may require Homebrew packages

### Linux

- Uses `~/.bashrc`
- Supports both bash and zsh
- Assumes GNU coreutils

## Maintenance

### Updating Plugins

Vim/Neovim:
```vim
:PackUpdate
```

### Backup

Important files are automatically backed up to `~/dotfiles/backup/` during installation if they already exist.

### Clean Installation

To reinstall on the same machine:

```bash
cd ~/dotfiles
python3 DotSetup.py --skip-user
```

## Contributing

This is a personal dotfiles repository, but feel free to fork and adapt for your own use.

## License

See [LICENSE](LICENSE) file for details.

## Version

Current revision: See `DotSetup.py` for version number
