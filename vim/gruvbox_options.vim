"=================================================================
" gruvbox Color Scheme {
"=================================================================
" <F5> to switch from dark to light
" <F6> to cycle the 3 levels of contrast
nnoremap <silent> <F5> :let &background = ( &background == "dark"? "light" : "dark" )<CR>
nnoremap <silent> <F6> :call GruvCycleContrast()<CR>

function! GruvCycleContrast()
    if &background ==? 'dark'
        if g:gruvbox_contrast_dark ==? 'soft'
            let g:gruvbox_contrast_dark='medium'
        elseif g:gruvbox_contrast_dark ==? 'medium'
            let g:gruvbox_contrast_dark='hard'
        elseif g:gruvbox_contrast_dark ==? 'hard'
            let g:gruvbox_contrast_dark='soft'
        endif
    else
        if g:gruvbox_contrast_light ==? 'soft'
            let g:gruvbox_contrast_light='medium'
        elseif g:gruvbox_contrast_light ==? 'medium'
            let g:gruvbox_contrast_light='hard'
        elseif g:gruvbox_contrast_light ==? 'hard'
            let g:gruvbox_contrast_light='soft'
        endif
    endif
    colorscheme gruvbox
endfunction

set background=dark            " Start with dark background theme
silent! colorscheme gruvbox    " Color scheme supports truecolor
"colorscheme default           " this is the default vim scheme
"} ===
