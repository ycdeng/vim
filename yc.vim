so ~/.vim/vim/asc.vim
so ~/.vim/vim/skywind.vim
let g:bundle_group = ['simple', 'basic', 'inter', 'opt', 'ale', 'echodoc', 'high', 'lightline', 'deoplete']
so ~/.vim/vim/ycbundle.vim

set clipboard=unnamedplus
set nu
set signcolumn=yes
" for lightline
set laststatus=2

map j gj
map k gk

Plug 'tomasiser/vim-code-dark'

if has("gui_running")
  " GUI is running or is about to start.
  " Maximize gvim window (for an alternative on Windows, see simalt below).
  set lines=999 columns=999
  colorscheme codedark
endif
set wrap linebreak nolist

set statusline+=%{gutentags#statusline()}

nnoremap <silent> <F5> :AsyncRun -raw -cwd=$(VIM_FILEDIR) "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>
nnoremap <silent> <F6> :AsyncRun -cwd=<root> -raw make check <cr>
nnoremap <silent> <F7> :AsyncRun -cwd=<root> make -j12 -s <cr>
nnoremap <silent> <F8> :AsyncRun -cwd=<root> -raw make distclean && ./configure --enable-cassert --enable-debug CFLAGS="-ggdb -Og -g3 -fno-omit-frame-pointer" <cr>
nnoremap <silent> <F9> :AsyncRun gcc -Wall -O2 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>

noremap <leader>]t :LeaderfTagCword<cr>
nnoremap <C-]> g<C-]>

set list
set listchars=tab:-->
hi SpecialKey ctermfg=239 guifg=#999999

" ignore .gitignore files
let g:gutentags_file_list_command = 'rg --files'
let g:gutentags_ctags_exclude = ['*.pm']

set autoread
au FocusLost * silent! wa

" deoplete autocomplete
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"

cabbrev wq w
noremap <silent>\gd :vertical Gstatus<cr>


set diffopt+=vertical