"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
"                __   _ _ _ __ ___  _ __ ___
"               \ \ / / | '_ ` _ \| '__/ __|
"                \ V /| | | | | | | | | (__
"                 \_/ |_|_| |_| |_|_|  \___|
"
"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


"=================================================================
" General Settings
"=================================================================
"=================================================================
" Behavior
"=================================================================
set nowritebackup           " only in case you don't want a backup file while editing
set noswapfile              " no swap files
set nocompatible               " Disable strct vi compatibility
set nobackup                   " Just overwrite the file
set printoptions=paper:letter,number:y,portrait:y
set shortmess+=filmnrxoOtT     " Abbrev. of messages (avoids 'hit enter')
set formatoptions+=tcq         " Basic formatting of text and comments
set wildmode=list:longest,full " Command <Tab> completion, list matches and
                               "   complete the longest common part, then,
                               "   cycle through the matches
set wildchar=<Tab>

"=================================================================
" tags
"=================================================================
:nmap ,t :!(cd %:p:h;ctags *)&
set tags=tags;


"=================================================================
" Editing
"=================================================================
autocmd! bufwritepost .vimrc source % " Automatic reloading of .vimrc
set backspace=indent,eol,start " Allow backspace over listed types
set nostartofline           " Stay on current char on page commands
set visualbell              " Don't beep, flash the screen instead
"set scrolloff=1            " Use a 1 line (horizontal) scroll offset
"set splitbelow             " Put the new window below the current one
set term=ansi               " Make 'ansi' the terminal type for editing
set encoding=utf8
set wildmenu
set commentstring=\ #\ %s

"=================================================================
" Status-line
"=================================================================
set ruler                   " Show the line / column number of cursor
set showcmd                 " Show the partially completed command
set showmode                " Display the current mode
set number                  " Display line number"
"set foldlevel=0
set clipboard =unnamed

"=================================================================
" Search
"=================================================================
set ignorecase             " Ignore case in search patterns
set smartcase              " Don't ignore case if pattern contains it
set incsearch              " Show the 'best match so far'
set hlsearch               " Don't highlight all matches

"=================================================================
" Programming
"=================================================================
if has("syntax")
  syntax on                    " Enable syntax-highlighting
endif

set autoindent                 " Keep indent level on new line
set nosmartindent                " Intelligent indenting for source code
set cindent                    " Intelligent indenting for source code
set cinkeys=0{,0},!^F,o,O,e    " default is: 0{,0},0),:,0#,!^F,o,O,e
set showmatch                  " Show matching brackets / parenthesis
set matchtime=3                " Show matching character for .3s

"=================================================================
" Vertical indenting
"=================================================================
set shiftwidth=4               " Number of spaces used for autoindents
set tabstop=4                  " Set the tab width to 4
set softtabstop=4              
set list                       " Visually displays tabs and EOL
set listchars=tab:\.\          " Show tabs as a period and space
set expandtab
set textwidth=0

"=================================================================
" Color Scheme
" mkdir -p ~/.vim/colors && cd ~/.vim/colors
" wget -O hvalle256mod.vim http://www.vim.org/scripts/download_script.php?src_id=13400
"=================================================================
set t_Co=256
color hvalle256mod
"
"highlight Normal guibg=lightyellow guifg=Black                                   
"highlight Cursor guibg=Green guifg=black                                         
"highlight NonText guibg=grey80 

"=================================================================
"augroup BufNewFileFromTemplate 
" Misc.
"=================================================================
filetype plugin indent on

" Return to the last position in the file
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif

"=================================================================
" Python File Template
"=================================================================
"au FileType python setlocal 	tabstop=4 expandtab shiftwidth=4 softtabstop=4
augroup BufNewFileFromTemplate
au!
autocmd BufNewFile * silent! 0r $HOME/.vim/templates/%:e.tpl
autocmd BufNewFile * normal! G"_dd1G
autocmd BufNewFile * silent! match Todo /TODO/
augroup BufNewFileFromTemplate

" Trim white spaces
"autocmd BufWritePre *.py normal m`:%s/\s\+$//e``

"---- Options for Windows
if has("gui_running")
	"set guifont=Courier  " use this font 
	set guifont="-bitstream-bitstream vera sans mono-bold-r-normal-*-*-80-*-*-m-*-microsoft-cp1252"
	set lines=50         " height = 50 lines
	set columns=100      " width = 100 columns
	set background=dark " adapt colors for dark background
	colorscheme kib_darktango " use this color scheme
	set selectmode=mouse,key,cmd
	set keymodel=
	behave mswin
	nmap <F5> :ls<CR>:e #
	nmap <F1> :bp<CR>
	nmap <F2> :bn<CR>
else
	set background=light  " adapt colors for dark background
	colorscheme default  " use this color scheme
endif

" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>

let g:miniBufExplSplitToEdge = 0
let g:miniBufExplVSplit = 30

"=================================================================
" PLUGINS 
"=================================================================

" Be iMproved
 set nocompatible
"=================================================================
" Set Bundle Manage Package
" Install the following git product:
" git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
"=================================================================
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

"=================================================================
" Let Vundle manage Vundle
" 
"  The bundles you install will be listed here:
"  Inside vim:
"    BundleList -> list of plugins
"    BundleInstall -> install plugin
"=================================================================
Bundle 'gmarik/vundle'
"
filetype plugin indent on


"=================================================================
" Highlight excess line lenght
"=================================================================
augroup vimrc_autocmds
    autocmd!
    " highlight characters past column 120
    autocmd FileType python highlight Excess ctermbg=DarkGrey guibg=Black
    autocmd FileType python match Excess /\%120v.*/
    autocmd FileType python set nowrap
augroup END

" Powerline
"Bundle 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
"
" Powerline setup
"set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 9
"set laststatus=2

"                    " Fugitive for GIT
"                    Bundle 'tpope/vim-fugitive'
"
"                    " NerdTree to see files in tree mode
"                    Bundle 'scrooloose/nerdtree'
"                    " Activate with F2
"                    map <C-t> :NERDTreeToggle<CR>
"                    let g:NERDTreeDirArrowExpandable = '*'
"                    let g:NERDTreeDirArrowCollapsible = '-'
"
"                    " Python Mode
"                    Bundle 'klen/python-mode'
"
"                    " Python
"                    au FileType python setlocal tabstop=8 expandtab
"                    shiftwidth=4 softtabstop=4
"                    augroup BufNewFileFromTemplate
"                    au!
"                    " Python Template
"                    autocmd BufNewFile * silent! 0r
"                    $HOME/.vim/templates/%:e.tpl
"                    autocmd BufNewFile * normal! G"_dd1G
"                    autocmd BufNewFile * silent! match Todo /TODO/
"                    augroup BufNewFileFromTemplate
"
"                    " Python-mode
"                    " Activate rope
"                    " Keys
"                    " K             Show python docs
"                    " <Ctrl-Space>  Rope autocomplete
"                    " <Ctrl-c>g     Rope goto definition
"                    " <Ctrl-c>d     Rope show documentation
"                    " <Ctrl-c>f     Rope find occurrences
"                    " <Leader>b     Set, unset breakpoint
"                    (g:pymode_breakpoint enabled)
"                    " [[            Jump on previous class or function
"                    (normal, visual, operator mod
"                    es)
"                    " ]]            Jump on next class or function (normal,
"                    visual, operator modes)
"                    " [M            Jump on previous class or method (normal,
"                    visual, operator modes
"                    )
"                    " ]M            Jump on next class or method (normal,
"                    visual, operator modes)
"                    " Do not use default rope, use jedi instead
"                    let g:pymode_rope = 0
"
"                    " Documentation
"                    let g:pymode_doc = 1
"                    let g:pymode_doc_key = 'K'
"
"                    "Linting
"                    let g:pymode_lint = 1
"                    let g:pymode_lint_checker = "pyflakes,pep8"
"                    " Auto check on save
"                    let g:pymode_lint_write = 1
"
"                    " Support virtualenv
"                    let g:pymode_virtualenv = 1
"
"                    " Enable breakpoints plugin
"                    let g:pymode_breakpoint = 1
"                    let g:pymode_breakpoint_bind = '<leader>b'
"
"                    " syntax highlighting
"                    let g:pymode_syntax = 1
"                    let g:pymode_syntax_all = 1
"                    let g:pymode_syntax_indent_errors = g:pymode_syntax_all
"                    let g:pymode_syntax_space_errors = g:pymode_syntax_all
"
"                    " Don't autofold code mode
"                    let g:pymode_folding = 0
"
"                    " Jedi code autocompletion
"                    Bundle 'davidhalter/jedi-vim'
"
"                    " Commant-T -> Fast open files, tags
"                    " Requires vim compile with Ruby
"                    "Bundle 'wincent/command-t'
"
"                    "Super tab completion
"                    Bundle 'ervandew/supertab'
"
"                    " Tags in right col.
"                    " Requires Exuberant Ctags
"                    Bundle 'majutsushi/tagbar'
