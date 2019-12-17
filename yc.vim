so ~/.vim/vim/asc.vim
so ~/.vim/vim/skywind.vim
let g:bundle_group = ['simple', 'basic', 'inter', 'ale', 'high', 'lightline', 'deoplete', 'lsp' ,'echodoc']
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
au FocusLost * silent! wa
" colors for listchars
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
nnoremap <silent> <F7> :AsyncRun -cwd=<root> -raw sudo make install<cr>
nnoremap <silent> <F8> :AsyncRun -cwd=<root> -raw make distclean && ./configure --enable-cassert --enable-debug CFLAGS="-ggdb -Og -g3 -fno-omit-frame-pointer" <cr>
nnoremap <silent> <F9> :AsyncRun gcc -Wall -O2 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr> q
nnoremap <C-]> g<C-]>
cabbrev wq w
call deoplete#custom#source('LanguageClient', 'rank', 100)
call deoplete#custom#source('omni', 'rank', 200)
call deoplete#custom#source('ale', 'rank', 200)
" zeal
nnoremap <leader>z :!zeal "<cword>"<CR><CR>
" insert mode
autocmd InsertEnter,InsertLeave * set cul!
nmap <silent> <leader>vs :exec '!code % &'
" makecheck orafce
nmap <silent> <leader>co :AsyncRun -mode=2 -cwd=<root>/contrib/orafce -raw make check <cr>
" quick fix window startup size
let g:asyncrun_open = 12

set completeopt=menu,noinsert
" turn off netrw banner
let g:netrw_banner = 0
" set termwinkey=<c-j>

" if match(getcwd(), "/pgsql") >=0 ||  match(getcwd(), "/postgresql") >= 0 ||  match(getcwd(), "/atlasdb") >= 0
"   set cinoptions=(0
"   set tabstop=4
"   set shiftwidth=4
" endif