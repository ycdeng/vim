so ~/.vim/vim/asc.vim
so ~/.vim/vim/skywind.vim


let g:bundle_group = ['simple', 'basic', 'inter', 'opt', 'ale', 'echodoc', 'high']
so ~/.vim/vim/bundle.vim

set clipboard=unnamedplus
set nu
set signcolumn=yes

Plug 'tomasiser/vim-code-dark'

if has("gui_running")
  " GUI is running or is about to start.
  " Maximize gvim window (for an alternative on Windows, see simalt below).
  set lines=999 columns=999
  colorscheme codedark
endif
set wrap linebreak nolist
map j gj
map k gk
set statusline+=%{gutentags#statusline()}


nnoremap <silent> <F5> :AsyncRun -raw -cwd=$(VIM_FILEDIR) "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>
nnoremap <silent> <F6> :AsyncRun -cwd=<root> -raw make check <cr>
nnoremap <silent> <F7> :AsyncRun -cwd=<root> make -j12 -s <cr>
nnoremap <silent> <F8> :AsyncRun -cwd=<root> -raw make distclean && ./configure --enable-cassert --enable-debug CFLAGS="-ggdb -Og -g3 -fno-omit-frame-pointer" <cr>
nnoremap <silent> <F9> :AsyncRun gcc -Wall -O2 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>
