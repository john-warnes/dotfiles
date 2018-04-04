"=================================================================
" ALE Linter <F8> to toggle {
"=================================================================
    "let g:ale_cpp_clang_options='-std=c14 -Wall'
    "let g:ale_cpp_cppcheck_options=' --enable=style'
    "let g:ale_cpp_gcc_options='-std=c++14 -Wall'

    "define cpp linters to stop cling-check as it has errors
    let g:ale_linters = {
                \    'cpp': ['clang','gcc', 'cppcheck', 'cpplint']
                \}

    "let g:ale_sign_column_always = 1        " Always show sign column
    let g:ale_sign_error = '>'
    let g:ale_sign_warning = '-'
    let g:ale_history_log_output=1           " :ALEInfo for full output
    if exists(':ALEToggle')
        nnoremap <F8> :ALEToggle<CR>
    endif
"} ===

