so ~/.vim/vim/asc.vim
so ~/.vim/vim/skywind.vim


let g:bundle_group = ['simple', 'basic', 'inter', 'opt', 'ale', 'echodoc']
so ~/.vim/vim/bundle.vim

set clipboard=unnamedplus
set nu
if has("gui_running")
  " GUI is running or is about to start.
  " Maximize gvim window (for an alternative on Windows, see simalt below).
  set lines=999 columns=999
  colorscheme dark_plus
endif
set wrap linebreak nolist
map j gj
map k gk
