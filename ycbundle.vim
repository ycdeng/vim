"----------------------------------------------------------------------
" system detection 
"----------------------------------------------------------------------
if exists('g:asc_uname')
	let s:uname = g:asc_uname
elseif has('win32') || has('win64') || has('win95') || has('win16')
	let s:uname = 'windows'
elseif has('win32unix')
	let s:uname = 'cygwin'
elseif has('unix')
	let s:uname = substitute(system("uname"), '\s*\n$', '', 'g')
	if !v:shell_error && s:uname == "Linux"
		let s:uname = 'linux'
	elseif v:shell_error == 0 && match(s:uname, 'Darwin') >= 0
		let s:uname = 'darwin'
	else
		let s:uname = 'posix'
	endif
else
	let s:uname = 'posix'
endif


let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')

function! s:path(path)
	let path = expand(s:home . '/' . a:path )
	return substitute(path, '\\', '/', 'g')
endfunc


"----------------------------------------------------------------------
" packages begin
"----------------------------------------------------------------------
if !exists('g:bundle_group')
	let g:bundle_group = []
endif

if !exists('g:bundle_post')
	let g:bundle_post = ''
endif

call plug#begin(get(g:, 'bundle_home', '~/.vim/bundles'))


"----------------------------------------------------------------------
" package group - simple
"----------------------------------------------------------------------
if index(g:bundle_group, 'simple') >= 0
	Plug 'easymotion/vim-easymotion'
	Plug 'Raimondi/delimitMate'
	Plug 'justinmk/vim-dirvish'
	Plug 'justinmk/vim-sneak'
	Plug 'tpope/vim-unimpaired'
	Plug 'tpope/vim-vinegar'
	Plug 'godlygeek/tabular', { 'on': 'Tabularize' }
	Plug 'bootleq/vim-cycle'
	Plug 'tpope/vim-surround'
	Plug 'plasticboy/vim-markdown'

	nnoremap gb= :Tabularize /=<CR>
	vnoremap gb= :Tabularize /=<CR>
	nnoremap gb/ :Tabularize /\/\//l4c1<CR>
	vnoremap gb/ :Tabularize /\/\//l4c1<CR>
	nnoremap gb, :Tabularize /,/r0l1<CR>
	vnoremap gb, :Tabularize /,/r0l1<CR>
	nnoremap gbl :Tabularize /\|<cr>
	vnoremap gbl :Tabularize /\|<cr>
	nnoremap gbc :Tabularize /#/l4c1<cr>
	nnoremap gb<bar> :Tabularize /\|<cr>
	vnoremap gb<bar> :Tabularize /\|<cr>
	nnoremap gbr :Tabularize /\|/r0<cr>
	vnoremap gbr :Tabularize /\|/r0<cr>
	map gz <Plug>Sneak_s
	map gZ <Plug>Sneak_S

	noremap <silent> <Plug>CycleFallbackNext <C-A>
	noremap <silent> <Plug>CycleFallbackPrev <C-X>
	nmap <silent> <c-a> <Plug>CycleNext
	vmap <silent> <c-a> <Plug>CycleNext
	nmap <silent> <c-x> <Plug>CyclePrev
	vmap <silent> <c-x> <Plug>CyclePrev
endif


"----------------------------------------------------------------------
" package group - basic
"----------------------------------------------------------------------
if index(g:bundle_group, 'basic') >= 0
	Plug 'tpope/vim-fugitive'
	
	Plug 'airblade/vim-gitgutter'
	nmap <Leader>hu <Plug>(GitGutterUndoHunk)

	Plug 'tomasiser/vim-code-dark'
	Plug 'puremourning/vimspector'
	Plug 'xolox/vim-misc'
	Plug 'terryma/vim-expand-region'

	Plug 'octol/vim-cpp-enhanced-highlight', { 'for': ['c', 'cpp'] }
	Plug 'justinmk/vim-syntax-extra', { 'for': ['c', 'bison', 'flex', 'cpp'] }
	Plug 'tpope/vim-commentary'
	
 	Plug 'Yggdroot/LeaderF', { 'do': './install.sh' }
	let g:Lf_ShortcutF = '<c-p>'
	let g:Lf_ShortcutB = '<m-n>'
	noremap <c-n> :cclose<cr>:Leaderf mru --regexMode<cr>
	noremap <m-p> :cclose<cr>:LeaderfFunction!<cr>
	noremap <m-P> :cclose<cr>:LeaderfBufTag!<cr>
	noremap <m-n> :cclose<cr>:LeaderfBuffer<cr>
	noremap <m-m> :cclose<cr>:LeaderfTag<cr>
	noremap <m-f> :cclose<cr>:Leaderf line --regexMode --nowrap<cr>
	noremap <leader>ff :<C-U><C-R>=printf("Leaderf! rg -e %s ", expand("<cword>"))<CR>
	" -w, --word-regexp
	noremap <leader>fr :cclose<cr>:Leaderf! rg --recall<cr>
	noremap <m-r> :cclose<cr>:Leaderf cmdHistory --regexMode --nowrap<cr>
	let g:Lf_GtagsAutoGenerate = 1
	let g:Lf_Gtagslabel = 'native-pygments'
	noremap <leader>gr :<C-U><C-R>=printf("Leaderf! gtags -r %s --auto-jump", expand("<cword>"))<CR><CR>
	noremap <leader>gd :<C-U><C-R>=printf("Leaderf! gtags -d %s --auto-jump", expand("<cword>"))<CR><CR>
	noremap <leader>gs :<C-U><C-R>=printf("Leaderf! gtags -s %s --auto-jump", expand("<cword>"))<CR><CR>
	noremap <leader>go :<C-U><C-R>=printf("Leaderf! gtags --recall %s", "")<CR><CR>
	noremap <leader>gn :<C-U><C-R>=printf("Leaderf gtags --next %s", "")<CR><CR>
	noremap <leader>gp :<C-U><C-R>=printf("Leaderf gtags --previous %s", "")<CR><CR>
	let g:Lf_MruMaxFiles = 2048
	let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }

	let g:cpp_class_scope_highlight = 1
	let g:cpp_member_variable_highlight = 1
	let g:cpp_class_decl_highlight = 1
	" let g:cpp_experimental_simple_template_highlight = 1
	let g:cpp_concepts_highlight = 1
	let g:cpp_no_function_highlight = 1

	let g:python_highlight_builtins = 1
	let g:python_highlight_builtin_objs = 1
	let g:python_highlight_builtin_types = 1
	let g:python_highlight_builtin_funcs = 1

	map <m-+> <Plug>(expand_region_expand)
	map <m-_> <Plug>(expand_region_shrink)
	let g:Lf_WindowPosition = 'bottom'
end


"----------------------------------------------------------------------
" package group - inter
"----------------------------------------------------------------------
if index(g:bundle_group, 'inter') >= 0
	Plug 'vim-scripts/L9'
	" Plug 'ludovicchabant/vim-gutentags'
	" Plug 'wsdjeg/FlyGrep.vim'
	" Plug 'tpope/vim-abolish'
	" Plug 'honza/vim-snippets'
	" Plug 'MarcWeber/vim-addon-mw-utils'
	Plug 'tomtom/tlib_vim'
	" Plug 'garbas/vim-snipmate'
	Plug 'vim-scripts/FuzzyFinder'
	Plug 'rust-lang/rust.vim', { 'for': 'rust' }
	" Plug 'xolox/vim-notes', { 'on': ['Note', 'SearchNotes', 'DeleteNotes', 'RecentNotes'] }
	Plug 'skywind3000/vimoutliner', { 'for': 'votl' }
	Plug 'mattn/webapi-vim'
	" Plug 'mattn/gist-vim'
	" Plug 'lambdalisue/vim-gista', { 'on': 'Gista' }
	" Plug 'Yggdroot/indentLine'

	if has('python') || has('python3')
		" Plug 'SirVer/ultisnips'
	endif

	if !isdirectory(expand('~/.vim/notes'))
		silent! call mkdir(expand('~/.vim/notes'), 'p')
	endif

	" noremap <silent><tab>- :FufMruFile<cr>
	" noremap <silent><tab>= :FufFile<cr>
	" noremap <silent><tab>[ :FufBuffer<cr>
	" noremap <silent><tab>] :FufBufferTag<cr>
endif


"----------------------------------------------------------------------
" package group - high
"----------------------------------------------------------------------
if index(g:bundle_group, 'high') >= 0
	Plug 'kshenoy/vim-signature'
	Plug 'mhinz/vim-signify'
	Plug 'mh21/errormarker.vim'
	Plug 't9md/vim-choosewin'
	Plug 'francoiscabrol/ranger.vim'
	Plug 'kana/vim-textobj-user'
	" Plug 'kana/vim-textobj-indent'
	Plug 'kana/vim-textobj-syntax'
	Plug 'kana/vim-textobj-function', { 'for':['c', 'cpp', 'vim', 'java'] }
	Plug 'sgur/vim-textobj-parameter'
	Plug 'bps/vim-textobj-python', {'for': 'python'}
	Plug 'jceb/vim-textobj-uri'

	let g:errormarker_disablemappings = 1
	nnoremap <silent> <leader>cm :ErrorAtCursor<CR>
	nnoremap <silent> [e :ErrorAtCursor<CR>
	nnoremap <silent> <leader>cM :RemoveErrorMarkers<cr>

	" nmap <m-e> <Plug>(choosewin)
	let g:ranger_map_keys = 0

end


"----------------------------------------------------------------------
" package group - opt
"----------------------------------------------------------------------
if index(g:bundle_group, 'opt') >= 0
	Plug 'junegunn/fzf'
	Plug 'mhartington/oceanic-next'
	Plug 'asins/vim-dict'
	Plug 'jceb/vim-orgmode', { 'for': 'org' }
	Plug 'soft-aesthetic/soft-era-vim'
	Plug 'dyng/ctrlsf.vim'
	Plug 'itchyny/calendar.vim', { 'on': 'Calendar' }
	Plug 'tpope/vim-speeddating'
	" Plug 'itchyny/vim-cursorword'
	let g:gutentags_modules = []
	if executable('ctags')
		let g:gutentags_modules += ['ctags']
	endif
	if len(g:gutentags_modules) > 0
		Plug 'ludovicchabant/vim-gutentags'
	endif
endif


"----------------------------------------------------------------------
" optional 
"----------------------------------------------------------------------

" deoplete
if index(g:bundle_group, 'deoplete') >= 0
	let g:python_host_prog = "/usr/bin/python2"
	let g:python3_host_prog = "/usr/bin/python3"
	if has('nvim')
		Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
	else
		Plug 'Shougo/deoplete.nvim'
		Plug 'roxma/nvim-yarp'
		Plug 'roxma/vim-hug-neovim-rpc'
	endif
	Plug 'Shougo/echodoc.vim'
	Plug 'Shougo/neosnippet.vim'
	Plug 'Shougo/neosnippet-snippets'
	" Plug 'zchee/deoplete-clang'
	" Plug 'zchee/deoplete-jedi'

	let g:deoplete#enable_at_startup = 1
	" let g:deoplete#enable_smart_case = 1
	" let g:deoplete#enable_refresh_always = 1

	let g:neosnippet#snippets_directory='~/.vim/vim/snippets'

	set shortmess+=c
	set noshowmode
	imap <m-e>     <Plug>(neosnippet_expand_or_jump)
	smap <m-e>     <Plug>(neosnippet_expand_or_jump)
	xmap <m-e>     <Plug>(neosnippet_expand_target)
	let g:deoplete#sources#jedi#enable_cache = 1
endif

" echodoc
if index(g:bundle_group, 'echodoc') >= 0
	Plug 'Shougo/echodoc.vim'
let g:echodoc#enable_at_startup = 1
let g:echodoc#type = 'signature'
endif

" airline
if index(g:bundle_group, 'airline') >= 0
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'
	let g:airline_left_sep = ''
	let g:airline_left_alt_sep = ''
	let g:airline_right_sep = ''
	let g:airline_right_alt_sep = ''
	let g:airline_powerline_fonts = 0
	let g:airline_exclude_preview = 1
	let g:airline_section_b = '%n'
	" let g:airline_section_z = '%P %l/%L%{g:airline_symbols.maxlinenr} : %v'
	" let g:airline_section_z = '%{AirlineLineNumber()}'
	" let g:airline_theme='bubblegum'
endif

" lightline
if index(g:bundle_group, 'lightline') >= 0
	Plug 'itchyny/lightline.vim'
endif

if index(g:bundle_group, 'nerdtree') >= 0
	Plug 'scrooloose/nerdtree', {'on': ['NERDTree', 'NERDTreeFocus', 'NERDTreeToggle', 'NERDTreeCWD', 'NERDTreeFind'] }
	Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
	let g:NERDTreeMinimalUI = 1
	let g:NERDTreeDirArrows = 1
	let g:NERDTreeHijackNetrw = 0
	" let g:NERDTreeFileExtensionHighlightFullName = 1
	" let g:NERDTreeExactMatchHighlightFullName = 1
	" let g:NERDTreePatternMatchHighlightFullName = 1
	noremap <space>tn :NERDTree<cr>
	noremap <space>to :NERDTreeFocus<cr>
	noremap <space>tm :NERDTreeMirror<cr>
	noremap <space>tt :NERDTreeToggle<cr>
endif

if index(g:bundle_group, 'grammer') >= 0
	Plug 'rhysd/vim-grammarous'
	noremap <space>rg :GrammarousCheck --lang=en-US --no-move-to-first-error --no-preview<cr>
	map <space>rr <Plug>(grammarous-open-info-window)
	map <space>rv <Plug>(grammarous-move-to-info-window)
	map <space>rs <Plug>(grammarous-reset)
	map <space>rx <Plug>(grammarous-close-info-window)
	map <space>rm <Plug>(grammarous-remove-error)
	map <space>rd <Plug>(grammarous-disable-rule)
	map <space>rn <Plug>(grammarous-move-to-next-error)
	map <space>rp <Plug>(grammarous-move-to-previous-error)
endif


if index(g:bundle_group, 'ale') >= 0
	Plug 'w0rp/ale'

	let g:airline#extensions#ale#enabled = 1
	let g:ale_linters = {
				\ 'c': ['clang', 'clangd'], 
				\ 'cpp': ['clang', 'clangd'], 
				\ 'python': ['flake8', 'pylint'], 
				\ 'lua': ['luac'], 
				\ 'go': ['go build', 'gofmt'],
				\ 'java': ['javac'],
				\ 'javascript': ['eslint'], 
				\ }

	function! s:lintcfg(name)
		let conf = s:path('tools/conf/')
		let path1 = conf . a:name
		let path2 = expand('~/.vim/linter/'. a:name)
		return shellescape(filereadable(path2)? path2 : path1)
	endfunc

	let g:ale_python_flake8_options = '--conf='.s:lintcfg('flake8.conf')
	let g:ale_python_pylint_options = '--rcfile='.s:lintcfg('pylint.conf')
	let g:ale_python_pylint_options .= ' --disable=W'
	let g:ale_c_gcc_options = '-Wall -O2 -std=c99'
	let g:ale_cpp_gcc_options = '-Wall -O2 -std=c++14'
	let g:ale_c_cppcheck_options = ''
	let g:ale_cpp_cppcheck_options = ''
	let g:ale_lua_luacheck_options = '-d'

	" let g:ale_linters.text = ['textlint', 'write-good', 'languagetool']
	" let g:ale_linters.lua += ['luacheck']
	
	" if executable('gcc') == 0 && executable('clang')
	" 	let g:ale_linters.c += ['clang', 'clangd']
	" 	let g:ale_linters.cpp += ['clang', 'clangd']
	" endif
endif

if index(g:bundle_group, 'neomake') >= 0
	Plug 'neomake/neomake'
endif


" if index(g:bundle_group, 'neocomplete') >= 0
" 	Plug 'Shougo/neocomplete.vim'
" 	let g:neocomplete#enable_at_startup = 1
" 	let g:neocomplete#sources#syntax#min_keyword_length = 2
" 	inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" 	inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
" 	inoremap <expr><C-g><C-g> neocomplete#undo_completion()
" 	inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
" 	function! s:my_cr_function()
" 		return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
" 	endfunction
" endif


if index(g:bundle_group, 'lsp') >= 0
	Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': 'bash install.sh' }
	let g:LanguageClient_loadSettings = 1
	let g:LanguageClient_diagnosticsEnable = 0
	let g:LanguageClient_settingsPath = expand('~/.vim/languageclient.json')
	let g:LanguageClient_selectionUI = 'quickfix'
	let g:LanguageClient_diagnosticsList = v:null
	let g:LanguageClient_hoverPreview = 'Never'
	" let g:LanguageClient_loggingLevel = 'DEBUG'
	if !exists('g:LanguageClient_serverCommands')
		let g:LanguageClient_serverCommands = {}
		let g:LanguageClient_serverCommands.c = ['clangd']
		let g:LanguageClient_serverCommands.cpp = ['clangd']
	endif

	nnoremap <leader>ld :call LanguageClient#textDocument_definition()<CR>
	nnoremap <leader>lr :call LanguageClient#textDocument_rename()<CR>
	nnoremap <leader>lf :call LanguageClient#textDocument_formatting()<CR>
	nnoremap <leader>lt :call LanguageClient#textDocument_typeDefinition()<CR>
	nnoremap <leader>lx :call LanguageClient#textDocument_references()<CR>
	nnoremap <leader>la :call LanguageClient_workspace_applyEdit()<CR>
	nnoremap <leader>lc :call LanguageClient#textDocument_completion()<CR>
	nnoremap <leader>lh :call LanguageClient#textDocument_hover()<CR>
	nnoremap <leader>ls :call LanguageClient_textDocument_documentSymbol()<CR>
	nnoremap <leader>lm :call LanguageClient_contextMenu()<CR>

endif

if index(g:bundle_group, 'keysound') >= 0
	Plug 'skywind3000/vim-keysound'
	let g:keysound_theme = 'default'
	let g:keysound_enable = 1
endif


"----------------------------------------------------------------------
" packages end
"----------------------------------------------------------------------
if exists('g:bundle_post')
	if type(g:bundle_post) == v:t_string
		exec g:bundle_post
	elseif type(g:bundle_post) == v:t_list
		exec join(g:bundle_post, "\n")
	endif
endif

call plug#end()



