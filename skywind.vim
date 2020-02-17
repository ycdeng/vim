"----------------------------------------------------------------------
" system detection
"----------------------------------------------------------------------
if has('win32') || has('win64') || has('win95') || has('win16')
	let g:asc_uname = 'windows'
elseif has('win32unix')
	let g:asc_uname = 'cygwin'
elseif has('unix') && (has('mac') || has('macunix'))
	let g:asc_uname = 'darwin'
elseif has('unix')
	let s:uname = substitute(system("uname"), '\s*\n$', '', 'g')
	if v:shell_error == 0 && match(s:uname, 'Linux') >= 0
		let g:asc_uname = 'linux'
	elseif v:shell_error == 0 && match(s:uname, 'FreeBSD') >= 0
		let g:asc_uname = 'freebsd'
	elseif v:shell_error == 0 && match(s:uname, 'Darwin') >= 0
		let g:asc_uname = 'darwin'
	else
		let g:asc_uname = 'posix'
	endif
else
	let g:asc_uname = 'posix'
endif


let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')



"----------------------------------------------------------------------
"- Global Settings
"----------------------------------------------------------------------

let g:ycm_goto_buffer_command = 'new-or-existing-tab'

if g:asc_uname == 'windows'
	let g:asyncrun_encs = 'gbk'
endif


"----------------------------------------------------------------------
"- FileType Preference
"----------------------------------------------------------------------
augroup SkywindGroup
	au!
	" au FileType python setlocal shiftwidth=4 tabstop=4 noexpandtab omnifunc=pythoncomplete#Complete
	au FileType python setlocal shiftwidth=4 tabstop=4 et omnifunc=pythoncomplete#Complete
	au FileType lisp setlocal ts=8 sts=2 sw=2 et
	au FileType scala setlocal sts=4 sw=4 noet
	au FileType haskell setlocal et
	au FileType cpp setlocal commentstring=//\ %s
augroup END


"----------------------------------------------------------------------
" config
"----------------------------------------------------------------------
let s:settings = {  
	\ 'cygwin': 'd:/linux',
	\ 'zeal': 'D:\Program Files\zeal-portable\zeal.exe',
	\ }

let s:settings_win = {
	\ 'emacs': 'd:/dev/emacs/bin/runemacs.exe',
	\ 'gdb' : 'd:/dev/mingw32/bin/gdb.exe',
	\ }

call asclib#setting#update(s:settings)

if has('win32') || has('win64') || has('win16') || has('win95')
	call asclib#setting#update(s:settings_win)
	if has('gui_running')

	endif
endif


"----------------------------------------------------------------------
" QuickMenu
"----------------------------------------------------------------------
call quickmenu#current(2)

if has('win32') || has('win64') || has('win16') || has('win95')
	call quickmenu#append('# Help', '')
	call quickmenu#append('Win32 Help', 'call menu#WinHelp("d:/dev/help/win32.hlp")', 'Looking up Win32 API')
	call quickmenu#append('MSDN of VC6', 'call menu#WinHelp("d:/dev/help/chm/vc.chm")', 'MSDN')
	call quickmenu#append('Python2 Help', 'call menu#WinHelp("d:/dev/help/chm/python2713.chm")', 'Python 2 Document')
	call quickmenu#append('Python3 Help', 'call menu#WinHelp("d:/dev/help/chm/python362.chm")', 'Python 3 Document')
	call quickmenu#append('Open Cygwin', 'call asclib#utils#terminal("mintty", "bash -i", 0)', 'open cygwin in current directoy')
	call quickmenu#append('Open Bash', 'call asclib#wsl_bash("")', 'open bash for windows 10 in current directory')
	call quickmenu#append('Open PowerShell', '!start powershell', 'open bash for windows 10 in current directory')
	call quickmenu#append('Switch color', 'call SkywindSwitchColor()', 'switch current color scheme')
endif


"----------------------------------------------------------------------
" keymaps 
"----------------------------------------------------------------------
if has('win32') || has('win16') || has('win64') || has('win95')
	noremap <space>hw :FileSwitch tabe e:/svn/doc/linwei/GTD.otl<cr>
else
endif


"----------------------------------------------------------------------
"- miscs
"----------------------------------------------------------------------

if g:asc_uname != 'windows'
	runtime ftplugin/man.vim
	nnoremap K :Man <cword><CR>
	let g:ft_man_open_mode = 'vert'
endif

let g:cppman_open_mode = '<auto>'


command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>

if executable('rg')
	let g:vimmake_grep_mode = 'rg'
endif


"----------------------------------------------------------------------
"- OptImport
"----------------------------------------------------------------------
" VimImport site/echofunc.vim
VimImport site/argtextobj.vim
VimImport site/indent-object.vim
" VimImport site/calendar.vim
"VimImport site/hilinks.vim

if has('gui_running')
	VimImport site/hexhigh.vim
endif

runtime! macros/matchit.vim


"----------------------------------------------------------------------
"- OmniCpp
"----------------------------------------------------------------------
let OmniCpp_NamespaceSearch = 1
let OmniCpp_GlobalScopeSearch = 1
let OmniCpp_ShowAccess = 1 
let OmniCpp_ShowPrototypeInAbbr = 1
let OmniCpp_MayCompleteDot = 1  
let OmniCpp_MayCompleteArrow = 1 
let OmniCpp_MayCompleteScope = 1
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]


"----------------------------------------------------------------------
"- bufferhint
"----------------------------------------------------------------------
if has('patch-8.2.1') || has('nvim-0.4')
	nnoremap <silent>+ :call quickui#tools#list_buffer('FileSwitch tabe')<cr>
else
	nnoremap + :call bufferhint#Popup()<CR>
endif

" let g:bufferhint_CustomHighlight = 1
" hi! default link KeyHint Statement
" hi! default link AtHint Identifier


"----------------------------------------------------------------------
" Enable vim-diff-enhanced (Christian Brabandt)
"----------------------------------------------------------------------
if has('patch-8.1.0388')
	set diffopt+=internal,algorithm:patience
	set diffopt+=indent-heuristic
endif



"----------------------------------------------------------------------
" color scheme
"----------------------------------------------------------------------
map <leader><F3> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
	\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
	\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

let g:solarized_termcolors=256

nnoremap <leader><F1> :call Tools_ProfileStart('~/.vim/profile.log')<cr>
nnoremap <leader><F2> :call Tools_ProfileStop()<cr>


"----------------------------------------------------------------------
" color scheme
"----------------------------------------------------------------------
let s:colors = ['biogoo', 'calmbreeze', 'dawn', 'dejavu', 'eclipse2', 'paradox', 'gaea', 'github', 'greyhouse', 'habiLight', 'imperial']
let s:colors += ['mayansmoke', 'mickeysoft', 'newspaper', 'nuvola', 'oceanlight', 'peaksea', 'pyte', 'summerfruit256', 'tomorrow']
let s:colors += ['monokai-vim']

function! SkywindSwitchColor()
	call asclib#color_switch(s:colors)
endfunc


"----------------------------------------------------------------------
" quickui
"----------------------------------------------------------------------
let g:quickui_tags_list = {
			\ 'python': '--python-kinds=fmc --language-force=Python',
			\ }

let g:quickui_tags_indent = {
			\ 'm': '  ',
			\ }

