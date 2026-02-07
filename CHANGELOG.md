# Changelog

All notable changes to the DotSetup project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0] - 2026-02-06

### Added
- Comprehensive backup and restore system with timestamped backups
- `--backup` flag to create backups without making changes
- `--backup-list` flag to list all available backups
- `--restore <N>` flag to restore from specific backup by index
- Automatic backup creation before any restore operation
- `--status` flag to display system information and tool versions
- Enhanced OS detection for Linux distributions, macOS, and Windows
- Version comparison system with visual indicators (✓/✗) for installed tools
- Recommended version checking for vim, nvim, tmux, ssh, gpg, and shell
- Fancy box drawing for formatted output with sections and titles
- Color-coded output using ANSI escape codes
- Support for minpac plugin manager installation
- SSH controlmasters directory creation for connection multiplexing
- Comprehensive type hints for Python 3.8+
- Modern Python dictionary type annotations

### Changed
- **BREAKING**: Upgraded to Python 3.8+ with modern type hints
- Refactored system data collection into dedicated `collect_system_data()` function
- Improved `display_system_data()` with version checking and color-coded status
- Enhanced file backup system with session-based backup directories
- Modernized shell, tmux, and vim configurations
- Updated recommended tool versions to current standards
- Improved error handling and user feedback throughout
- Better symlink management with proper cleanup of existing files/links
- Enhanced `export_dot_files()` to handle existing configurations intelligently

### Fixed
- Backup file path handling for .gitconfig
- Removed unused `expanduser` dependency in backup path
- Support for running setup from any directory
- Updating existing gitconfig instead of only overwriting

### Documentation
- Added inline documentation for complex functions
- Improved docstrings with parameter descriptions and examples
- Better code organization with clear section divisions

## [3.5] - 2022-08-18

### Added
- New `--skip-user` flag to install without prompting for user data
- Automatic .rc file creation if they don't exist
- Support for IDE spellchecker with .vscode/settings
- `git stats-commits` alias to show commit statistics by author

### Changed
- Revamped and updated DotSetup script for reliability
- Cleanup and refactor code with current Python style updates
- Reverted to Type hints compatible with older Python versions

### Fixed
- Bugfix for `git stats-commits` alias

## [3.4] - 2022-09-20

### Added
- Uniform function naming convention

### Changed
- Updated backup system for .gitconfig files

### Fixed
- Bugfix in create SSH user script
- Removed unnecessary sudo access requests
- Fixed backup path dependency issues

## [3.3] - 2022-09-14

### Added
- gitconfig default branch set to `main`
- Support for updating existing gitconfig (not just overwriting)
- Ability to run setup from any directory

### Changed
- Updated install.sh script
- Upgraded git-stats script with help documentation
- Added bash completion to autorun.sh

## [3.2] - 2022-09-13

### Changed
- Vim and NeoVim are no longer required, but still recommended
- Added install.sh for auto-install support with VS Code

## [3.1] - 2022-08-30

### Added
- c_locale file for locale configuration
- Random password support in create-ssh-user script
- Safety check for already existing home folders

### Changed
- Unified create-ssh-user print statements

### Fixed
- Fixed create-ssh-user.sh issues

## [3.0] - 2022-08-19

### Added
- Git prompt support for ash shell
- Improved color support for Alpine Linux in containers
- Basic colors and modes to colors.sh using ESC codes instead of tput

### Changed
- Create .rc files if they don't exist

## [2.9] - 2022-07-15

### Added
- Improved Zsh support
- Improved Neovim support
- recurse.sh script
- 24-bit color detection scripts

### Changed
- Updated git-prompt
- Moved 24-bit-color.sh to scripts directory
- Renamed environment variable: `DOTFILES` → `DOT_FILES`

## [2.8] - 2022-07-01

### Added
- parallel_commands script for running commands in parallel

## [2.7] - 2022-04-14

### Added
- Improved macOS zsh support
- New create-ssh-user script

## [2.6] - 2022-01-13

### Added
- adb_tool with `-s` flag for shell mode

### Changed
- Updated to support new tmux versions

## [2.5] - 2020-12-18

### Added
- Aliases for default Ubuntu mount folders
- Flutter bash completion

### Changed
- Indented and updated default gitconfig

## [2.4] - 2020-12-09

### Added
- Helper script (ExportEnv.sh) for importing .env files into environment
- Scripts path added to autorun

### Changed
- Updated to use bash arrays for argument lists

## [2.3] - 2020-03-31

### Changed
- Changed minimum vim version to 8.0

## [2.2] - 2020-03-18

### Added
- adb_ss.sh script for Android debugging
- cleandups.sh script

### Changed
- Cleaned up various scripts
- Updated Python DotSetup

## [Unreleased]

### Planned
- Additional plugin manager support
- Enhanced cross-platform compatibility
- Automated testing framework
- Configuration validation

---

## Version History

- **4.0.0**: Major overhaul with backup/restore system, modern Python, enhanced UI
- **3.x**: User data management, gitconfig improvements, shell enhancements
- **2.x**: Cross-platform support, script additions, vim/tmux updates

[4.0.0]: https://github.com/yourusername/dotfiles/compare/v3.5...v4.0.0
[3.5]: https://github.com/yourusername/dotfiles/compare/v3.4...v3.5
