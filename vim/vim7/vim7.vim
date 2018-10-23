"=================================================================
" Vim-Plug auto Install {
"=================================================================
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    augroup plugmanager
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC | q
    augroup end
endif
"} ===

call plug#begin('~/.vim/bundle')

" Normal
Plug 'john-warnes/jvim'                     " Jvim
Plug 'morhetz/gruvbox'                      " Color scheme

" Extra
Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' } " Tag listing
Plug 'christoomey/vim-tmux-navigator'       " tmux integration
Plug 'godlygeek/tabular'                    " Text aliment tool

Plug 'lifepillar/vim-mucomplete'            " Builtin chainable autocomplete

" ################## DISABLED PLUGINS ##################
"Plug 'tweekmonster/startuptime.vim'         " Startup profiler :StartupTime

call plug#end()
"===============================================================================
"=###########################= END Plugin System =#############################=
"}==============================================================================
