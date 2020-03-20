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
set listchars=tab:-->
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
map j gj
map k gk
nnoremap ; :
nnoremap : <nop>
noremap  <silent><F1> :call quickmenu#toggle(0)<cr>
inoremap <silent><F1> <ESC>:call quickmenu#toggle(0)<cr>
noremap <silent><F2> :call quickmenu#toggle(1)<cr>
inoremap <silent><F2> <ESC>:call quickmenu#toggle(1)<cr>
cabbrev wq w
cabbrev q bd


set completeopt=menu,noinsert
" turn off netrw banner
let g:netrw_banner = 0

let g:gutentags_define_advanced_commands = 1
let $GTAGSLABEL = 'native-pygments'
let $GTAGSCONF = '/usr/local/share/gtags/gtags.conf'

let @d = "\<C-w>vgf\<C-w>hbjjgf:windo diffthis\<CR>"

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
hi TabLineFill ctermfg=LightGreen ctermbg=DarkGreen
hi TabLine ctermfg=Blue ctermbg=Yellow
hi TabLineSel ctermfg=Red ctermbg=Yellow

autocmd InsertEnter * highlight CursorLine cterm=NONE ctermbg=28
autocmd InsertLeave * highlight CursorLine cterm=NONE ctermbg=24


set clipboard=unnamedplus

let g:asynctasks_rtp_config = get(g:, 'asynctasks_rtp_config', 'yc.ini')

call quickui#menu#reset()

call quickui#menu#install("&File", [
			\ [ "&Open\t(:w)", 'call feedkeys(":tabe ")'],
			\ [ "&Save\t(:w)", 'write'],
			\ [ "--", ],
			\ [ "LeaderF &File", 'Leaderf file', 'Open file with leaderf'],
			\ [ "LeaderF &Mru", 'Leaderf mru --regexMode', 'Open recently accessed files'],
			\ [ "LeaderF &Buffer", 'Leaderf buffer', 'List current buffers in leaderf'],
			\ [ "--", ],
			\ [ "J&unk File", 'JunkFile', ''],
			\ ])

" quick fix enchencemant

nnoremap <silent><space><space> :call quickui#menu#open()<cr>
let g:asynctasks_term_pos = 'quickfix'
" noremap <silent><F10> :vertical botright copen 60<cr>
" inoremap <silent><F10> <ESC>:vertical botright copen 60<cr>

autocmd FileType qf wincmd L
function! ToggleQuickFix()
for winnr in range(1, winnr('$'))
  if getwinvar(winnr, '&syntax') == 'qf'
    cclose
  else
	cope
  endif
endfor
endfunction

" nmap <script> <silent> <F2> :call ToggleQuickFix()<CR>
noremap <silent><F3> :call ToggleQuickFix()<cr>
inoremap <silent><F3> :call ToggleQuickFix()<cr>

" noremap <silent><space>fd :call Open_Dictionary("<C-R>=expand("<cword>")<cr>")<cr>
" noremap <silent><space>fm :!man -S 3:2:1 "<C-R>=expand("<cword>")"<CR>
noremap <silent><space>fh :CocCommand clangd.switchSourceHeader<cr>
" noremap <silent><space>ff :call Open_Explore(-1)<cr>
" noremap <silent><space>ft :call Open_Explore(0)<cr>
" noremap <silent><space>fe :call Open_Explore(1)<cr>
" noremap <silent><space>fo :call Open_Explore(2)<cr>
" noremap <silent><space>fb :TagbarToggle<cr>
" noremap <silent><space>fp :call Tools_Pydoc("<C-R>=expand("<cword>")<cr>", 1)<cr>
" noremap <silent><space>fs :mksession! ~/.vim/session.txt<cr>
" noremap <silent><space>fl :so ~/.vim/session.txt<cr>


" show cursor line only on active window
augroup CursorLine
    au!
    au VimEnter * setlocal cursorline
    au WinEnter * setlocal cursorline
    au BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END

"  first clear the highlighting and then redraw the screen.
nnoremap <C-l> :nohl<CR><C-L>