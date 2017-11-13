# john-warnes/dotfiles.git

Install Script for Advanced dotfiles and vim setup.

## Features
- Neovim and Vim 8 Supported
- Termnal vim and GUI vim supported
- Gurvbox color scheme integrated
- ALE / Symatic Code linter
- Nerdtree
- Tagbar
- Tmux Shell Multiplexer
- Zsh Shell Support
- Changing Fonts
- UltiSnips
- Python Mode
- Bash customisation
- Encrypted personal alises
- .gitconfig
- Useful shell scripts
- c/c++/python templates
- Custom simple auto metadata
- Many more...

## Theme ScreenShots
Default Dark Setup  
![Default Color Scheme](/_assets/Default.png "Default Color Scheme")

Default Light Setup  
![Default Light Color Scheme](/_assets/LightMode.png "Default Light Color Scheme")

Not sure what one to pick? Try `<F5>`  
![Dark or Light](/_assets/Dark_or_Light.gif "Dark or Light Color Scheme")

Need more contrast for theme? Try `<F6>`  
![Dark Contrasts](/_assets/Dark_Contrasts.gif "Dark Contrasts")
![Light Contrasts](/_assets/Light_Contrasts.gif "Light Contrasts")

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

## Supported OS
 - Linux
 - Mac OSX
 - Ubunutu on windows 10
 - Babun


## Controls  
### Map Leader
map leader = `,`  

### Fonts (gnome-terminal only)
`<F7>` Cycle through installed powerline fonts  
`<Ctrl+'+'>` Font size bigger  
`<Ctrl+'-'>` Font size smaller  

### Theme
`<F5>` Cycle Dark and Light Mode  
`<F6>` Cycle through three levels of contrast  

### Function Mapping
`<Leader>s` Do Sort  
`<Crtl+b>` Open Tree Browser  
`<Crtl+t>` Open Tag Browser  
`<t><t>` Cycle opening folded code blocks  

### Movement using vim standard keys
`<Ctrl+[h,j,k,l]>` Move to vim panes and tmux windows (vim-tmux-navigator)  
`<Leader>m` Move next tab  
`<Leader>n` Move prev tab  

### Movement using arrow keys
  note: Many window managers intercept arrow key combos  
`<Ctrl+[Left,Right,Up,Down]>` to change windows and tabs  
`<Alt+[Left,Right]>` to move current tab  
`<Crtl+PageUp>` or `<Ctrl+PageDown` to change tabs  

# Includes the JVim Plugin  
# Documentation for the JVim Plugin  

# JVim Plugin
Version 2.0  

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

## Features
- Fixing Quickfix Window Size
- Folding Defaults
- Use detected file sytnax for code folding support
- Automatically return to the last position of previously edited files
- Spell check on by default
- Mouse support for terminal vim
- Use system clipboard for vim
- Show trailing white space
- Show EOL marked (off by default)
- Show many hidden characters: Tabs, NBSP, Extends, Precedes
- Show simple indent guide for <space> indented files
- Persistent Undo (undo saved on a previously edited file)
- Many helpful <Arrow Key> mapping for the new users
    - Same mappings supported with regular vim movement keys
- Many other useful key mapping

## Options
Place options before your `Plug 'john-warnes/jvim'` line in vimrc  
Options shown with defaults  
```
let g:JV_vimDir             = $HOME/.vim         " Setup Vim Directory
let g:JV_showTrailing       = 1                  " Show Tailing Spaces
let g:JV_showEol            = 0                  " Show EOL marker
let g:JV_usePresistent_Undo = 1                  " Use persistent Undo
let g:JV_colorColumn        = 81                 " Set long line guide
let g:JV_red                = 'GruvboxRedBold'   " Highlight link for Red
let g:JV_useSystemClipboard = 1                  " Try to use system clipboard
let g:JV_IndentGuide        = 1                  " Show indent guides when (F2 Toggle)
let g:JV_codePretty         = 1                  " Replace some chars with alternatives (F2 Toggle)
let g:JV_quickFixHeightMin  = 3                  " Limit the MIN size of the quick fix window
let g:JV_quickFixHeightMax  = 10                 " Limit the MAX size of the quick fix window
let g:JV_foldingSyntax      = 1                  " Enable fold=syntax for all files
                                                 " NOTE:Might be slow on older systems
let g:JV_foldingDefault     = 2                  " Folding Mode on File Open
                                                 "   0 no default (might remember last)
                                                 "   1 open all folds on file open
                                                 "   2 close all folds on file open
                                                 "   NOTE: ''tt'' in normal mode to toggle folds
let g:JV_DateFormat         = '%A, %d %B %Y'     " Format for template and metadata dates (man date)
let g:JV_MaxMetaDataSearch  = 50                 " Max lines at top of file to search for meta data tags
let g:JV_EnableUpdateMetaData = 1                " Enable auto updating of metadata on file save
```

### Window Creation/Deletion
`<Ctrl+w><Del>` or `<C-w><BackSpace>` to close current window  
`<Ctrl+w>|` or `<Ctrl+w>\` Create new file in vertical split window  
`<Ctrl+w>-` or `<Ctrl+=>` Create new file in horizontal split window  
*NOTE* Use the *mouse* for easy control over window splits `[Click]` and `[Drag]` on window the *separator*  

### Window and Tab Movement
`<C-PageUp>` and `<C-PageDown>` Change current tab  
`<Ctrl+Left>` and `<Ctrl+Right>` Move cursor to *Left/Right Window*, or if at screen edge change to *Next/Prev Tab*  
`<Ctrl+Up>` and `<Ctrl+Down>` Move cursor to *Up/Down Window*  
`<Leader><Arrow Key>` does the same as `<Ctrl+Arrow Key>`  
`<Alt+Left>` Move current tab left  
`<Alt+Right>` Move current tab right  

### Commands
`:TrimFile` Trim trailing white space(s) from current file  
`:w!!` Force saving current file with *sudo* (protected file)  

### Visual Mode
`<tab>` Jump to matching braces, parentheses, etc..
`<` or `>` Indent or unindent lines selected lines

### Normal Mode

#### Code Folding
`<t><t>` Toggle open/close current fold  
`<z><M>` Close *all* folds  
`<z><R>` Open *all* folds  

#### Files
`<f><t>` open file *under cursor* in *new tab* (or current file)  
`<f><f>` open file *under cursor* in new *vertical split* window (or current file)  

#### Search
`<Leader>/` or `<Ctrl+n>` Clear current search highlight  
`<leader>p` Manually toggle *Paste Mode* use if you have problems pasting into vim from outside programs  

#### Movement
`<tab>` Jump to matching (braces, parentheses, etc)  

#### Display
`<F2>` Show/hide indent guides and CodePretty()  

Indent guide example  
![Indent Guide Example](/_assets/Indet_Flip.gif "Indent Guides")

Example of codePretty text changes  
![Indent Guide Example](/_assets/codePretty.gif "codePretty")

#### Spelling Help
`==` to autocorrect word under cursor  
`z=` to list possible corrections of word under cursor  
`u`  to undo  

#### GUI menu
`<F4>` Open Terminal version of the GUI menu  
- Use `<Left>`, `<Right>` or `<Tab>` to navigate  
- `<Enter>` to select  
- `<Esc>` to quit  

#### Vim Scripting
`<Shift+F5>` re-source current file (vim files only)  

### Other fixes

#### Command Mode
`:Q` becomes `q`  
`:Q!` becomes `q!`  
`:W` becomes `w`  
`:W!` becomes `w!`  


