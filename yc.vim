so ~/.vim/vim/asc.vim
so ~/.vim/vim/skywind.vim
let g:bundle_group = ['simple', 'basic', 'inter', 'ale', 'high', 'lightline', 'deoplete', 'lsp' ,'echodoc', 'opt']
so ~/.vim/vim/ycbundle.vim

set clipboard=unnamedplus
set nu
set signcolumn=yes
" for lightline
set laststatus=2
set wrap linebreak
set autoread
au CursorHold * checktime  
set statusline+=%{gutentags#statusline()}
set diffopt+=vertical
set list
set listchars=tab:--#
" disable bracket jump when complete
set matchtime=0
autocmd CursorHold,CursorHoldI * update
" colors for listchars
colorscheme codedark
hi SpecialKey ctermfg=239 guifg=#999999


Plug 'tomasiser/vim-code-dark'

if has("gui_running")
  " GUI is running or is about to start.
  " Maximize gvim window (for an alternative on Windows, see simalt below).
  set lines=999 columns=999
  colorscheme codedark
endif

" ignore using .gitignore files
let g:gutentags_file_list_command = 'rg --files'
" ignore filetype
let g:gutentags_ctags_exclude = ['*.pm']

" keymaps
noremap <silent>\gst :vertical Gstatus<cr>
map j gj
map k gk
nnoremap ; :
nnoremap <silent> <F5> :AsyncRun -raw -cwd=$(VIM_FILEDIR) "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>
nnoremap <silent> <F6> :AsyncRun -cwd=<root> -raw make check <cr>
nnoremap <silent> <F7> :AsyncRun -cwd=<root> -raw make install<cr>
" nnoremap <silent> <F8> :AsyncRun -cwd=<root> -raw make distclean && ./configure --enable-cassert --enable-debug CFLAGS="-ggdb -Og -g3 -fno-omit-frame-pointer" <cr>
" nnoremap <silent> <F9> :AsyncRun gcc -Wall -O2 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr> q
" nnoremap <C-]> g<C-]>
cabbrev wq w
cabbrev q bd
call deoplete#custom#source('LanguageClient', 'rank', 100)
call deoplete#custom#source('omni', 'rank', 200)
call deoplete#custom#source('ale', 'rank', 200)

set completeopt=menu,noinsert
" turn off netrw banner
let g:netrw_banner = 0

let g:gutentags_define_advanced_commands = 1
let $GTAGSLABEL = 'native-pygments'
let $GTAGSCONF = '/usr/local/share/gtags/gtags.conf'

let @d = "\<C-w>vgf\<C-w>hjjgf:windo diffthis\<CR>"

" easymotion 高亮
hi Search cterm=NONE ctermbg=green ctermfg=white

" 高亮当前行
set cursorline

" 高亮当前行
" hi CursorLine cterm=NONE ctermbg=blue
hi CursorLine cterm=NONE ctermbg=24
hi Folded cterm=NONE ctermbg=red ctermfg=white
hi VertSplit cterm=NONE ctermfg=white ctermbg=8
hi StatusLine ctermfg=white ctermbg=250 cterm=NONE
hi StatusLineNC ctermfg=white ctermbg=238 cterm=NONE

autocmd InsertEnter * highlight CursorLine cterm=NONE ctermbg=28
autocmd InsertLeave * highlight CursorLine cterm=NONE ctermbg=24


