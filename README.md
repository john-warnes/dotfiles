# john-warnes/dotfiles.git

## Instillation
1. Clone into `$HOME` folder  
```
~/git clone https://github.com/john-warnes/dotfiles.git
```
2. Change into dotfiles folder  
```
~/ ch dotfiles`
```
3. Run DotSetup.sh  
```
~/dotfiles/ ./DotSetup.sh
```
or
```
~/dotfiles/ bash DotSetup.sh
```
4. Answer setup questions  
4. Enjoy jvim

## Features
- gurvbox color scheme integrated
- ALE or Symatic Code linterer
- Nerdtree with git support
- Tagbar
- Tmux
- Zsh



# Documentation for the JVim Plugin

## Installation
Install this plugin as you would any other vim plugin  
Vundle example:
```
Plugin 'john-warnes/jvim'
```
vim-plug example:
```
Plug 'john-warnes/jvim'
```
### Features
- Use detected file sytnax for code folding support
- Automatically return to the last position of previously edited files
- Spell check on by default
- Mouse support for terminal vim
- Use system clipboard for vim
- Show trailing white space
- Show EOL marked (off by default)
- Show many hidden characters: Tabs, NBSP, Extends, Precedes
- Show simple indent guide for <space> indented files
- Persistent Undo (undo on a previously edited file)
- Many helpful <Arrow Key> mapping for the new users
    - Same mapping support with regular vim movement keys
- Many other useful key mapping

## Options
Place options before your `Plug 'john-warnes/jvim'` line in vimrc  
Options shown with defaults  
```
g:JV_vimDir="$HOME/.vim"                  "Setup Vim Directory
g:JV_showTrailing = 1                     "Show Trailing Spaces
g:JV_showEol = 0                          "Show EOL marker
g:JV_showIndentGuides = 1                 "Show Indents
g:JV_usePresistentUndo = 1                "Use persistent Undo
g:JV_colorColumn = join(range(81,83),',') "Set Long Line guide
g:JV_red = 'GruvboxRedBold'               "Highlight link for Red
g:JV_useSystemClipboard = 1               "Use System Clipboard
```

## Commands

### GUI menu
`F4` Open Terminal version if the GUI menu  
- Use movement left and right or `<Tab>` to navagate  
- `<Enter>` to select  
- `<Esc>` to quit  

### File Commands
`:TrimFile` to trim trailing white space  
`ff` open filename under cursor in new vsplit  
`ft` open filename under cursor in new tab  

### Code Folding
`<tab><tab>` to open and close a code fold  
or when cursor is over fold push left or right movement keys  

### Window Commands
`<C-w><Del>` or `<C-w><BackSpace>` to close current window  
`<C-w>|` Create new vertical split in window  
`<C-w>-` Create new horizontal split in window  
Use the mouse for easy control over window splits  
- Click and drag on window separator  

### Tabs
Change Tabs with `<C-PageUp>` and `<C-PageDown>`

### Saving
`:w!!` Save with sudo (in case you edited protected file and forgot)

### Spelling Help
`==` to autocorrect word under cursor  
`z=` to list possible corrections of word under cursor  
`u`  to undo  

Common CMD misspelling mappings
`:Q` becomes `q`  
`:Q!` becomes `q!`  
`:W` becomes `w`  
`:W!` becomes `w!`  

### Indent Guide (Spaces for indents)
`F2` to toggle on or off  
![Indent Guide Example](/_assets/Indet_Flip.gif "Indent Guides")

