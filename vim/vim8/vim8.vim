if !( has('job') && has('packages') )
    finish
endif

" get current script path
let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

" load options for ale
execute 'source ' . s:path . '/' . 'ale_options.vim'

" Use .vim even on windows
set packpath^=~/.vim

" Try to load minpac.
silent! packadd minpac

if exists('*minpac#init')
    " Initalize plugin system
    call minpac#init()

    " minpac must have {'type': 'opt'} so that it can be loaded with `packadd`.
    call minpac#add('k-takata/minpac', {'type': 'opt'})

    " Important Plugins
    call minpac#add('john-warnes/jvim')    " Jvim
    call minpac#add('morhetz/gruvbox')     " Color Scheme

    " More Plugins
    call minpac#add('majutsushi/tagbar')              " Tag listing
    call minpac#add('christoomey/vim-tmux-navigator') " tmux integration
    call minpac#add('godlygeek/tabular')              " Text aliment tool

    " Vim 8
    call minpac#add('lifepillar/vim-mucomplete')      " Builtin chainable autocomplete
    call minpac#add('dense-analysis/ale')             " async linting engine


    "call minpac#update()

    " Load the plugins right now. (optional)
    " Plugins need to be added to runtimepath before helptags can be generated.
    "packloadall
    " Load all of the helptags now, after plugins have been loaded.
    " All messages and errors will be ignored.
    "silent! helptags ALL

    " Define user commands for updating/cleaning the plugins.
    " Each of them loads minpac, reloads .vimrc to register the
    " information of plugins, then performs the task.
    command! PackUpdate packadd minpac | source $MYVIMRC | call minpac#update() | packloadall | silent! helptags ALL
    command! PackClean  packadd minpac | source $MYVIMRC | call minpac#clean()

    " echom "minpac loaded"
endif
