"=================================================================
" Gnome-Terminal ONLY {
"=================================================================
" <F7> cycle though mono powerline fonts
let g:powerlineFonts= [
            \'DejaVu Sans Mono for Powerline',
            \'Droid Sans Mono for Powerline',
            \'Droid Sans Mono Dotted for Powerline',
            \'Droid Sans Mono Slashed for Powerline',
            \'Fria Mono for Powerline'
            \'Go Mono for Powerline',
            \'Hack',
            \'Inconsolata for Powerline',
            \'Inconsolata-dz for Powerline',
            \'Inconsolata-g for Powerline',
            \'Literation Mono Powerline',
            \'Monofur for Powerline',
            \'Noto Mono for Powerline',
            \'NovaMono for Powerline',
            \'Roboto Mono for Powerline',
            \'Space Mono for Powerline'
            \'Ubuntu Mono derivative Powerline',
            \]

let g:font='DejaVu Sans Mono for Powerline'
let g:fontsize='11'

if has('gui_running')
    set guifont=DejaVu\ Sans\ Mono\ for\ Powerline
endif

function! GnomeTermSetFont()
    call system ("dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/font \"\'" . g:font . ' ' . g:fontsize . "\'\"")
endfunction

function! GnomeTermCycleFont()
    call add(g:powerlineFonts, g:font)
    let g:font = get(g:powerlineFonts,0,'mono')
    let g:powerlineFonts=g:powerlineFonts[1:]
    call system ("dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/font \"\'" . g:font . ' ' . g:fontsize . "\'\"")
    echom g:font
endfunction

" Cycle fonts with Gnome Terminal
nnoremap <F8> :call GnomeTermCycleFont()<CR>
"} ===
