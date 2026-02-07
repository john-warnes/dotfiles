# DotSetup - Dotfiles Management System

This is a cross-platform dotfiles management system for Linux and macOS, written in Python 3.8+ with a sophisticated backup/restore system.

## Core Architecture

### Main Entry Point: DotSetup.py
- **Purpose**: Python-based dotfiles installer with backup/restore capabilities
- **Key Features**: Symlink management, version checking, user configuration, timestamped backups
- **Design Pattern**: Single monolithic script (~1000 lines) with clear function separation
- **Dependencies**: `packaging` library for version comparison (pip3 install packaging)

### Installation Flow
1. `collect_system_data()` - Detect OS, shell, installed tool versions
2. `backup_all()` - Create timestamped backup in `backup/YYYYMMDD_HHMMSS/`
3. `ask_user_data()` - Collect name, email, company (unless `--skip-user`)
4. `create_user_vim()` - Generate `vim/user.vim` with user variables
5. `create_user_git()` - Configure `git/gitconfig` with user info
6. `create_folders()` - Ensure `~/.config/nvim/`, `~/.ssh/controlmasters/` exist
7. `install_minpac()` - Clone minpac plugin manager to `vim/pack/minpac/opt/minpac`
8. `create_sys_links()` - Create symlinks: `~/dotfiles/vim → ~/.vim`, `vim/vimrc → ~/.vimrc`, etc.
9. `export_dot_files()` - Append `export DOT_FILES=~/dotfiles` to `~/.bashrc`/`~/.zshrc`

### Critical Symlinks Created
```
~/dotfiles/vim → ~/.vim
~/dotfiles/vim/vimrc → ~/.vimrc
~/dotfiles/tmux/tmux.conf → ~/.tmux.conf
~/dotfiles/git/gitconfig → ~/.gitconfig
~/dotfiles/nvim/init.vim → ~/.config/nvim/init.vim
```

## Development Commands

### Testing/Running Setup
```bash
# Full install (asks for user info)
python3 DotSetup.py --install

# Quick install (skips user prompts, preserves existing configs)
python3 DotSetup.py --skip-user

# System status (check installed versions)
python3 DotSetup.py --status

# Create backup without changes
python3 DotSetup.py --backup

# List backups
python3 DotSetup.py --backup-list

# Restore from most recent backup
python3 DotSetup.py --restore

# Restore from specific backup (by index from --backup-list)
python3 DotSetup.py --restore 2
```

### Shell Installation (Simplified)
```bash
./install.sh  # Wrapper that runs DotSetup.py --skip-user
```

## Project-Specific Conventions

### Version Handling
- **Recommended versions** defined in `SETTINGS["recommended"]` dict
- Version comparison uses `packaging.version.parse()` for semantic versioning
- Visual indicators: `✓` (meets/exceeds), `✗` (below recommendation)
- Example: vim 8.2 vs recommended 8.0 → ✓

### Backup System
- **Location**: `~/dotfiles/backup/YYYYMMDD_HHMMSS/`
- **Auto-backup**: Before install and restore operations
- **Contents**: gitconfig, init.vim, user.vim, .bashrc, .zshrc, etc.
- **Restore safety**: Creates backup before restoring (prevent data loss)

### User-Specific Files (Git-ignored)
- `vim/user.vim` - Generated during install, contains:
  ```vim
  let g:_NAME_    = 'John Smith'
  let g:_USER_    = 'jsmith'
  let g:_COMPANY_ = 'Example Corp'
  let g:_EMAIL_   = 'jsmith@example.com'
  ```
- `vim/undo/` - Vim persistent undo files
- `vim/view/` - Vim view files (fold states)
- `vim/pack/minpac/start/` - Installed vim plugins

### Platform Detection Pattern
```python
SYS_DATA["os_kind"] = platform.system()  # "Linux", "Darwin", "Windows"
# OS-specific logic:
if SYS_DATA["os_kind"] == "Darwin":
    # macOS uses ~/.bash_profile instead of ~/.bashrc
    # ls uses -G flag instead of --color=auto
```

### Shell Configuration Chain
1. User sources `~/.bashrc` (Linux) or `~/.bash_profile` (macOS)
2. Those files export `DOT_FILES=~/dotfiles` and `CLICOLOR=1`
3. Then source `$DOT_FILES/shell/autorun.sh`
4. `autorun.sh` sources: `shell_aliases`, `git-prompt.sh`, `flutter_bash_completion.sh`, etc

## Key Files & Their Roles

### git/gitconfig
- Template with placeholders replaced during install
- Includes custom aliases: `git s`, `git logpretty`, `git logshort`
- Fast-forward only pulls, `main` as default branch

### vim/vimrc
- Main vim config (shared between vim 8 and neovim)
- Sources `vim/user.vim` for user-specific variables
- Plugin management via minpac (`:PackUpdate` to install)

### nvim/init.vim
- Thin wrapper: `source ~/dotfiles/vim/vimrc`
- Symlinked to `~/.config/nvim/init.vim`

### tmux/tmux.conf
- Version detection for tmux 2.9+ vs 3.0+
- True color support (`set-option -sa terminal-overrides ',xterm-256color:RGB'`)
- Custom prefix indicator in status bar: `[^A]` when prefix active

### scripts/git-stats
- Custom tool for commit statistics by author
- Usage: `git-stats --author "John" --days 60`

## Common Tasks

### Adding a New Configuration File
1. Add file to appropriate directory (`shell/`, `vim/`, `git/`, etc.)
2. If it needs to be symlinked to home, update `create_sys_links()` function
3. If user-specific, add to `.gitignore` and backup list in `backup_all()`

### Modifying System Detection
Edit `collect_system_data()` function to:
- Detect new tools: Add version check similar to existing patterns
- Update OS detection: Modify OS-specific blocks (Linux/Darwin/Windows)

### Updating Recommended Versions
Modify `SETTINGS["recommended"]` dict at top of DotSetup.py:
```python
"recommended": {
    "vim": "8.0",
    "nvim": "0.7.0",
    "tmux": "3.0",
    ...
}
```

### Version Management (CRITICAL)
**When updating the version number in DotSetup.py:**
1. Update `SETTINGS["version"]` at the top of DotSetup.py
2. Update the `Version:` in the file header
3. **DO NOT update `Modified:` date or `Revision:` number** - These are automatically updated by a script
4. **ALWAYS update CHANGELOG.md** with:
   - New version section following [Keep a Changelog](https://keepachangelog.com/) format
   - Date in format `[X.Y.Z] - YYYY-MM-DD`
   - Sections: Added, Changed, Fixed, Removed, Deprecated, Security
   - Document ALL changes since the last version
5. **Review and update README.md** if:
   - New features require documentation
   - Commands or usage patterns have changed
   - Prerequisites or installation steps have changed
   - New configuration options are available

## Testing Considerations

### Safe Testing Pattern
```bash
# 1. Create backup first
python3 DotSetup.py --backup

# 2. Test changes
python3 DotSetup.py --skip-user

# 3. If broken, restore
python3 DotSetup.py --restore
```

### Version Compatibility
- **Python**: Requires 3.8+ (uses modern dict type hints `dict[str, Any]`)
- **Vim**: Supports 7.4+, recommends 8.0+
- **Neovim**: Supports 0.2.0+, recommends 0.7.0+
- **Tmux**: Handles 2.9+ and 3.0+ (different theme syntax)

## Important Patterns

### Box Drawing (Terminal UI)
`box_draw()` function creates bordered text boxes with ANSI colors:
```python
box_draw("System Information", title="OS", width=60, align="<")
```

### Safe File Appending
`safe_append()` in `export_dot_files()` checks if lines already exist before appending to prevent duplicates in `.bashrc`/`.zshrc`.

### Symlink Management
Always check if destination exists before creating symlink:
```python
if os.path.islink(dest): os.unlink(dest)
elif os.path.isfile(dest): os.remove(dest)
elif os.path.isdir(dest): shutil.rmtree(dest)
os.symlink(src, dest)
```

## Gotchas

- **Don't run from arbitrary directories**: Script uses `os.path.dirname(__file__)` to find dotfiles root
- **Git operations**: Script modifies `git/gitconfig` directly, then symlinks to `~/.gitconfig`
- **Shell reload required**: After install, user must close terminal or `source ~/.bashrc` to activate
- **Vim plugins**: Manual step after install: `:PackUpdate` in vim to download plugins
- **macOS vs Linux**: Different shell config files (`.bash_profile` vs `.bashrc`)
