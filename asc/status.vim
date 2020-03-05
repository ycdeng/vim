

"----------------------------------------------------------------------
" simple status line
"----------------------------------------------------------------------
let g:status_padding_left = ""
let g:status_padding_right = ""

set statusline=                                 " clear status line
set statusline+=%{''.g:status_padding_left}     " left padding
set statusline+=\ %F                            " filename
set statusline+=\ [%1*%M%*%n%R%H]               " buffer number and status
set statusline+=%{''.g:status_padding_right}    " left padding
" set statusline+=\ %{''.toupper(mode())}         " INSERT/NORMAL/VISUAL
set statusline+=%=                              " right align remainder
set statusline+=\ %y                            " file type
set statusline+=\ %0(%{&fileformat}\ [%{(&fenc==\"\"?&enc:&fenc).(&bomb?\",BOM\":\"\")}]\ %v:%l/%L%)


set statusline=
set statusline+=%#DiffAdd#%{(mode()=='n')?'\ \ NORMAL\ ':''}
set statusline+=%#DiffChange#%{(mode()=='i')?'\ \ INSERT\ ':''}
set statusline+=%#DiffDelete#%{(mode()=='r')?'\ \ RPLACE\ ':''}
set statusline+=%#Cursor#%{(mode()=='v')?'\ \ VISUAL\ ':''}
set statusline+=%#CursorIM#     " colour

set statusline+=%{&paste?'\ PASTE\ ':''}
set statusline+=%{&spell?'\ SPELL\ ':''}
" set statusline+=%#CursorIM#     " colour
set statusline+=%R                        " readonly flag
set statusline+=%M                        " modified [+] flag
" set statusline+=%#Cursor#               " colour
set statusline+=\ %F\                   " short file name
" set statusline+=%#CursorLine#     " colour
set statusline+=%=                          " right align
set statusline+=\ %Y\                   " file type
set statusline+=\ %3l:%-2c\         " line + column
set statusline+=\ %3p%%\                " percentage