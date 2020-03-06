"======================================================================
"
" keymaps.vim - keymaps start with using <space>
"
" Created by skywind on 2016/10/12
" Last Modified: 2018/05/02 13:05
"
"======================================================================

"----------------------------------------------------------------------
" VimTools
"----------------------------------------------------------------------
for s:index in range(10)
	let s:button = (s:index > 0)? 'F'.s:index : 'F10'
	exec 'noremap <space>'.s:index.' :VimTool ' . s:index . '<cr>'
	if has('gui_running')
		exec "noremap <C-".s:button."> :VimTool c".s:index . '<cr>'
		exec "inoremap <C-".s:button."> <ESC>:VimTool c".s:index . '<cr>'
	endif
endfor


" keymap for VimTool
if (has('gui_running') || has('nvim')) && (has('win32') || has('win64'))
	let s:keys = [')', '!', '@', '#', '$', '%', '^', '&', '*', '(']
	for s:index in range(10)
		let s:name = ''.s:index
		if s:index == 0 | let s:name = '10' | endif
		exec 'noremap <silent><M-'.s:keys[s:index].'> :VimTool '.s:index.'<cr>'
		exec 'inoremap <silent><M-'.s:keys[s:index].'> <ESC>:VimTool '.s:index.'<cr>'
	endfor
else
	" require to config terminal to remap key alt-shift+? to '\033[{0}?~'
	for s:index in range(10)
		let s:name = ''.s:index
		if s:index == 0 | let s:name = '10' | endif
	endfor
endif


"----------------------------------------------------------------------
" window control
"----------------------------------------------------------------------
noremap <silent><space>= :resize +3<cr>
noremap <silent><space>- :resize -3<cr>
noremap <silent><space>, :vertical resize -3<cr>
noremap <silent><space>. :vertical resize +3<cr>

nnoremap <silent><c-w><c-e> :ExpSwitch edit<cr>
nnoremap <silent><c-w>e :ExpSwitch edit<cr>
nnoremap <silent><c-w>m :ExpSwitch vs<cr>
nnoremap <silent><c-w>M :ExpSwitch tabedit<cr>

noremap <silent><space>hh :nohl<cr>
noremap <silent><bs> :nohl<cr>:redraw!<cr>
" noremap <silent><tab>, :call Tab_MoveLeft()<cr>
" noremap <silent><tab>. :call Tab_MoveRight()<cr>
" noremap <silent><tab>6 :VinegarOpen leftabove vs<cr>
" noremap <silent><tab>7 :VinegarOpen vs<cr>
" noremap <silent><tab>8 :VinegarOpen belowright sp<cr>
" noremap <silent><tab>9 :VinegarOpen tabedit<cr>
" noremap <silent><tab>0 :exe "NERDTree ".fnameescape(expand("%:p:h"))<cr>
" noremap <silent><tab>y :exe "NERDTree ".fnameescape(vimmake#get_root("%"))<cr>
" noremap <silent><tab>g <c-w>p

noremap <silent><space>ha :GuiSignRemove
			\ errormarker_error errormarker_warning<cr>

" replace
noremap <space>p viw"0p
noremap <space>y yiw

" fast save
noremap <C-S> :w<cr>
inoremap <C-S> <ESC>:w<cr>

if !has('gui_running')
	nnoremap Q :confirm qall<cr>
endif


"----------------------------------------------------------------------
" space + e : vim control
"----------------------------------------------------------------------
noremap <silent><space>eh :call Tools_SwitchSigns()<cr>
noremap <silent><space>en :call Tools_SwitchNumber()<cr>


"----------------------------------------------------------------------
" Movement Enhancement
"----------------------------------------------------------------------
" noremap <M-h> b
" noremap <M-l> w
" noremap <M-j> gj
" noremap <M-k> gk
" inoremap <M-h> <c-left>
" inoremap <M-l> <c-right>
" inoremap <M-j> <c-\><c-o>gj
" inoremap <M-k> <c-\><c-o>gk
" inoremap <M-y> <c-\><c-o>d$
" cnoremap <M-h> <c-left>
" cnoremap <M-l> <c-right>
" cnoremap <M-b> <c-left>
" cnoremap <M-f> <c-right>


"----------------------------------------------------------------------
" fast window switching: ALT+SHIFT+HJKL
"----------------------------------------------------------------------
" noremap <m-H> <c-w>h
" noremap <m-L> <c-w>l
" noremap <m-J> <c-w>j
" noremap <m-K> <c-w>k
" inoremap <m-H> <esc><c-w>h
" inoremap <m-L> <esc><c-w>l
" inoremap <m-J> <esc><c-w>j
" inoremap <m-K> <esc><c-w>k


"----------------------------------------------------------------------
" gui hotkeys - alt + ?
"----------------------------------------------------------------------
if has('gui_running') || (has('nvim') && (has('win32') || has('win64')))
	noremap <silent><A-o> :call Open_Browse(2)<cr>
	inoremap <silent><A-o> <ESC>:call Open_Browse(2)<cr>
	noremap <S-cr> o<ESC>
	noremap <c-cr> O<esc>
	noremap <M-Left> :call Tab_MoveLeft()<cr>
	noremap <M-Right> :call Tab_MoveRight()<cr>
	inoremap <M-Left> <ESC>:call Tab_MoveLeft()<cr>
	inoremap <M-Right> <ESC>:call Tab_MoveRight()<cr>
	if has('gui_macvim')
		noremap <m-\|> :call Toggle_Transparency(9)<cr>
	else
		noremap <m-\|> :call Toggle_Transparency(15)<cr>
	endif
	if has('win32') || has('win64') || has('win16')
		noremap <silent><m-f> :AsyncRun -mode=0 -cwd=<root> mingw32-make -f Makefile<cr>
		noremap <silent><m-g> :AsyncRun -mode=4 -cwd=<root> mingw32-make -f Makefile test<cr>
	else
		noremap <silent><m-f> :AsyncRun -mode=0 -cwd=<root> make -f Makefile<cr>
		noremap <silent><m-g> :AsyncRun -mode=4 -cwd=<root> make -f Makefile test<cr>
	endif
endif

" nnoremap <m-z> za
" nnoremap <m-Z> zA


"----------------------------------------------------------------------
" terminal
"----------------------------------------------------------------------
if has('terminal')
	" tnoremap <m-=> <c-w>N
endif


"----------------------------------------------------------------------
" space + s : svn
"----------------------------------------------------------------------
" noremap <space>sc :AsyncRun svn co -m "update from vim"<cr>
" noremap <space>su :AsyncRun svn up<cr>
" noremap <space>st :AsyncRun svn st<cr>

" editing commands
" noremap <space>aa ggVG


"----------------------------------------------------------------------
" space + j : make
"----------------------------------------------------------------------
" noremap <silent><space>jj  :AsyncRun -cwd=<root> make<cr>
" noremap <silent><space>jc  :AsyncRun -cwd=<root> make clean<cr>
" noremap <silent><space>jk  :AsyncRun -mode=4 -cwd=<root> make run<cr>
" noremap <silent><space>jl  :AsyncRun -mode=4 -cwd=<root> make test<cr>
" noremap <silent><space>j1  :AsyncRun -mode=4 -cwd=<root> make t1<cr>
" noremap <silent><space>j2  :AsyncRun -mode=4 -cwd=<root> make t2<cr>
" noremap <silent><space>j3  :AsyncRun -mode=4 -cwd=<root> make t3<cr>
" noremap <silent><space>j4  :AsyncRun -mode=4 -cwd=<root> make t4<cr>
" noremap <silent><space>j5  :AsyncRun -mode=4 -cwd=<root> make t5<cr>
" noremap <silent><space>k1  :AsyncRun -cwd=<root> make t1<cr>
" noremap <silent><space>k2  :AsyncRun -cwd=<root> make t2<cr>
" noremap <silent><space>k3  :AsyncRun -cwd=<root> make t3<cr>
" noremap <silent><space>k4  :AsyncRun -cwd=<root> make t4<cr>
" noremap <silent><space>k5  :AsyncRun -cwd=<root> make t5<cr>

noremap <silent><space>jm :call Tools_SwitchMakeFile()<cr>


"----------------------------------------------------------------------
" space + t : toggle plugins
"----------------------------------------------------------------------
noremap <silent><M-;> :call quickui#tools#preview_tag('')<cr>
noremap <silent><M-:> :PreviewClose<cr>
noremap <silent><tab>; :PreviewGoto edit<cr>
noremap <silent><tab>: :PreviewGoto tabe<cr>

if has('autocmd')
	function! s:quickfix_keymap()
		if &buftype != 'quickfix'
			return
		endif
		nnoremap <silent><buffer> p :call quickui#tools#preview_quickfix()<cr>
		nnoremap <silent><buffer> P :PreviewClose<cr>
		nnoremap <silent><buffer> q :close<cr>
		setlocal nonumber
	endfunc
	function! s:insert_leave()
		if get(g:, 'echodoc#enable_at_startup') == 0
			set showmode
		endif
	endfunc
	augroup AscQuickfix
		autocmd!
		autocmd FileType qf call s:quickfix_keymap()
		autocmd InsertLeave * call s:insert_leave()
		" autocmd InsertLeave * set showmode
	augroup END
endif

nnoremap <silent><m-a> :PreviewSignature<cr>
inoremap <silent><m-a> <c-\><c-o>:PreviewSignature<cr>


"----------------------------------------------------------------------
" GUI/Terminal
"----------------------------------------------------------------------
noremap <silent><M-[> :call Tools_QuickfixCursor(2)<cr>
noremap <silent><M-]> :call Tools_QuickfixCursor(3)<cr>
noremap <silent><M-{> :call Tools_QuickfixCursor(4)<cr>
noremap <silent><M-}> :call Tools_QuickfixCursor(5)<cr>
noremap <silent><M-u> :call Tools_PreviousCursor(6)<cr>
noremap <silent><M-d> :call Tools_PreviousCursor(7)<cr>

inoremap <silent><M-[> <c-\><c-o>:call Tools_QuickfixCursor(2)<cr>
inoremap <silent><M-]> <c-\><c-o>:call Tools_QuickfixCursor(3)<cr>
inoremap <silent><M-{> <c-\><c-o>:call Tools_QuickfixCursor(4)<cr>
inoremap <silent><M-}> <c-\><c-o>:call Tools_QuickfixCursor(5)<cr>
inoremap <silent><M-u> <c-\><c-o>:call Tools_PreviousCursor(6)<cr>
inoremap <silent><M-d> <c-\><c-o>:call Tools_PreviousCursor(7)<cr>


"----------------------------------------------------------------------
" space + f : open tools
"----------------------------------------------------------------------
" noremap <silent><space>fd :call Open_Dictionary("<C-R>=expand("<cword>")<cr>")<cr>
" noremap <silent><space>fm :!man -S 3:2:1 "<C-R>=expand("<cword>")"<CR>
" noremap <silent><space>fh :call Open_HeaderFile(1)<cr>
" noremap <silent><space>ff :call Open_Explore(-1)<cr>
" noremap <silent><space>ft :call Open_Explore(0)<cr>
" noremap <silent><space>fe :call Open_Explore(1)<cr>
" noremap <silent><space>fo :call Open_Explore(2)<cr>
" noremap <silent><space>fb :TagbarToggle<cr>
" noremap <silent><space>fp :call Tools_Pydoc("<C-R>=expand("<cword>")<cr>", 1)<cr>
" noremap <silent><space>fs :mksession! ~/.vim/session.txt<cr>
" noremap <silent><space>fl :so ~/.vim/session.txt<cr>

set ssop-=options    " do not store global and local values in a session
" set ssop-=folds      " do not store folds

for s:index in range(5)
	exec 'noremap <silent><space>f'.s:index.'s :mksession! ~/.vim/session.'.s:index.'<cr>'
	exec 'noremap <silent><space>f'.s:index.'l :so ~/.vim/session.'.s:index.'<cr>'
endfor


"----------------------------------------------------------------------
" leader + b/c : buffer
"----------------------------------------------------------------------
" noremap <silent><leader>bc :BufferClose<cr>
noremap <silent><leader>cw :call Change_DirectoryToFile()<cr>


"----------------------------------------------------------------------
" space + h : fast open files
"----------------------------------------------------------------------
" noremap <space>hp :FileSwitch tabe ~/.vim/project.txt<cr>
" " noremap <space>hl :FileSwitch tabe ~/.vim/cloud/Documents/agenda.otl<cr>
" " noremap <space>hf <c-w>gf
" " noremap <space>he :call Show_Explore()<cr>
" " noremap <space>hb :FileSwitch tabe ~/.vim/bundle.vim<cr>
" " noremap <space>hq :FileSwitch tabe ~/.vim/quicknote.txt<cr>
" " noremap <space>hg :FileSwitch tabe ~/.vim/scratch.txt<cr>
" " noremap <space>hd :FileSwitch tabe ~/Dropbox/Documents/notes.txt<cr>
" " noremap <space>ho :FileSwitch tabe ~/.vim/cloud/Documents/cloudnote.txt<cr>
" " noremap <space>hi :FileSwitch tabe ~/.vim/tasks.ini<cr>
" " noremap <space>h; :call asclib#nextcloud_sync()<cr>

if (!has('nvim')) && (has('win32') || has('win64'))
	noremap <space>hr :FileSwitch tabe ~/_vimrc<cr>
elseif !has('nvim')
	noremap <space>hr :FileSwitch tabe ~/.vimrc<cr>
else
	noremap <space>hr :FileSwitch tabe ~/.config/nvim/init.vim<cr>
endif

let s:filename = expand('<sfile>:p')
exec 'nnoremap <space>hk :FileSwitch tabe '.fnameescape(s:filename).'<cr>'
let s:skywind = fnamemodify(s:filename, ':h:h'). '/skywind.vim'
exec 'nnoremap <space>hs :FileSwitch tabe '.fnameescape(s:skywind).'<cr>'
let s:bundle = fnamemodify(s:filename, ':h:h'). '/bundle.vim'
exec 'nnoremap <space>hv :FileSwitch tabe '.fnameescape(s:bundle).'<cr>'
let s:asclib = fnamemodify(s:filename, ':h:h'). '/autoload/asclib.vim'
exec 'nnoremap <space>hc :FileSwitch tabe '.fnameescape(s:asclib).'<cr>'
let s:auxlib = fnamemodify(s:filename, ':h:h'). '/autoload/auxlib.vim'
exec 'nnoremap <space>hu :FileSwitch tabe '.fnameescape(s:auxlib).'<cr>'
let s:tasks = fnamemodify(s:filename, ':h:h'). '/tasks.ini'
exec 'nnoremap <space>ht :FileSwitch tabe '.fnameescape(s:tasks).'<cr>'
let s:nvimrc = expand("~/.config/nvim/init.vim")
if has('win32') || has('win16') || has('win95') || has('win64')
	let s:nvimrc = expand("~/AppData/Local/nvim/init.vim")
endif
exec 'nnoremap <space>hn :FileSwitch tabe '.fnameescape(s:nvimrc).'<cr>'




"----------------------------------------------------------------------
" visual mode
"----------------------------------------------------------------------
vnoremap <space>gp :!python<cr>
" vmap <space>gs y/<c-r>"<cr>
vmap <space>gs y/<C-R>=escape(@", '\\/.*$^~[]')<CR>
vmap <space>gr y:%s/<C-R>=escape(@", '\\/.*$^~[]')<CR>//gc<Left><Left><Left>


"----------------------------------------------------------------------
" linting
"----------------------------------------------------------------------
noremap <silent><space>lp :call asclib#lint_pylint('')<cr>
noremap <silent><space>lf :call asclib#lint_flake8('')<cr>
noremap <silent><space>ls :call asclib#lint_splint('')<cr>
noremap <silent><space>lc :call asclib#lint_cppcheck('')<cr>
noremap <silent><space>lg :call asclib#open_gprof('', '')<cr>
noremap <silent><space>lt :call asclib#html_prettify()<cr>


"----------------------------------------------------------------------
" more personal in gvim
"----------------------------------------------------------------------
if has('gui_running') && (has('win32') || has('win64'))
	noremap <S-F11> :AsyncRun -mode=4 -cwd=$(VIM_FILEDIR) -save=1 d:\\software\\anaconda3\\python.exe "$(VIM_FILENAME)"<cr>
	inoremap <S-F11> <ESC>:AsyncRun -mode=4 -cwd=$(VIM_FILEDIR) d:\\software\\anaconda3\\python.exe "$(VIM_FILENAME)"<cr>
	noremap <S-F12> :AsyncRun -mode=4 -save=1 -cwd=$(VIM_FILEDIR) d:\\dev\\python64\\python.exe "$(VIM_FILENAME)"<cr>
endif

noremap <C-F10> :VimBuild gcc -pg<cr>


"----------------------------------------------------------------------
" vimmake faster
"----------------------------------------------------------------------


noremap <silent><c-f10> :call quickmenu#toggle(1)<cr>
inoremap <silent><c-f10> <ESC>:call quickmenu#toggle(1)<cr>
noremap <silent><c-f11> :call quickmenu#toggle(2)<cr>
inoremap <silent><c-f11> <ESC>:call quickmenu#toggle(2)<cr>
" noremap <silent><c-f12> :call asclib#utils#script_menu()<cr>
" inoremap <silent><c-f12> <ESC>:call asclib#utils#script_menu()<cr>

nnoremap <silent>g5 :PreviewTag<cr>
nnoremap <silent>g6 :call vimmake#update_tags('!', 'cs', '.cscope')<cr>
nnoremap <silent>g7 :call vimmake#update_tags('!', 'py', '.cscopy')<cr>
nnoremap <silent>g9 :call vimmake#update_tags('!', 'ctags', '.tags')<cr>

nnoremap <silent><space>ww :call asclib#touch_file('wsgi')<cr>

noremap <space>m0 :call quickmenu#toggle(0)<cr>
noremap <space>m1 :call quickmenu#toggle(1)<cr>
noremap <space>m2 :call quickmenu#toggle(2)<cr>
noremap <space>m3 :call quickmenu#toggle(3)<cr>


"----------------------------------------------------------------------
" others
"----------------------------------------------------------------------
nnoremap <silent><space>at :MyCheatSheetAlign<cr>
vnoremap <silent><space>at :MyCheatSheetAlign<cr>

noremap <m-i> :call quickui#tools#list_function()<cr>
noremap <m-I> :call quickui#tools#list_function()<cr>
noremap <m-y> :call quickui#tools#list_function()<cr>


"----------------------------------------------------------------------
" neovim system clipboard
"----------------------------------------------------------------------
if has('nvim') && (has('win32') || has('win64'))
	nnoremap <s-insert> "*P
	vnoremap <s-insert> "-d"*P
	inoremap <s-insert> <c-r><c-o>*
	vnoremap <c-insert> "*y
endif


