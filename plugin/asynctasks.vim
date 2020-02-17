"======================================================================
"
" asynctasks.vim - 
"
" Maintainer: skywind3000 (at) gmail.com, 2020
"
" Last Modified: 2020/02/17 04:28
" Verision: 1.4.5
"
" for more information, please visit:
" https://github.com/skywind3000/asynctasks.vim
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :


"----------------------------------------------------------------------
" internal variables
"----------------------------------------------------------------------
let s:windows = has('win32') || has('win64') || has('win16') || has('win95')
let s:scriptname = expand('<sfile>:p')
let s:scripthome = fnamemodify(s:scriptname, ':h:h')


"----------------------------------------------------------------------
" default values
"----------------------------------------------------------------------

" system
if !exists('g:asynctasks_system')
	let g:asynctasks_system = (s:windows == 0)? 'unix' : 'win'
endif

" task profile
if !exists('g:asynctasks_profile')
	let g:asynctasks_profile = 'debug'
endif

" local config
if !exists('g:asynctasks_config_name')
	let g:asynctasks_config_name = '.tasks'
endif

" global config in every runtimepath
if !exists('g:asynctasks_rtp_config')
	let g:asynctasks_rtp_config = 'tasks.ini'
endif

" global config
if !exists('g:asynctasks_extra_config')
	let g:asynctasks_extra_config = []
endif

" config by vimrc
if !exists('g:asynctasks_tasks')
	let g:asynctasks_tasks = {}
endif

" terminal mode: tab/curwin/top/bottom/left/right/quickfix/external
if !exists('g:asynctasks_term_pos')
	let g:asynctasks_term_pos = 'quickfix'
endif

" width of vertical terminal split
if !exists('g:asynctasks_term_cols')
	let g:asynctasks_term_cols = ''
endif

" height of horizontal terminal split
if !exists('g:asynctasks_term_rows')
	let g:asynctasks_term_rows = ''
endif

" set to non-zero to change focus when open a terminal in a split
if !exists('g:asynctasks_term_focus')
	let g:asynctasks_term_focus = 1
endif

" make internal terminal tab reusable
if !exists('g:asynctasks_term_reuse')
	let g:asynctasks_term_reuse = 0
endif

" whether set bufhidden to 'hide' in terminal window
if !exists('g:asynctasks_term_hidden')
	let g:asynctasks_term_hidden = 0
endif



"----------------------------------------------------------------------
" internal object
"----------------------------------------------------------------------
let s:private = { 'cache':{}, 'rtp':{}, 'local':{}, 'tasks':{} }
let s:error = ''
let s:index = 0


"----------------------------------------------------------------------
" internal function
"----------------------------------------------------------------------

" display in cmdline
function! s:errmsg(msg)
	redraw | echo '' | redraw
	echohl ErrorMsg
	echom 'Error: ' . a:msg
	echohl NONE
	let s:index += 1
endfunc

" trim leading & trailing spaces
function! s:strip(text)
	return substitute(a:text, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunc

" partition
function! s:partition(text, sep)
	let pos = stridx(a:text, a:sep)
	if pos < 0
		return [a:text, '', '']
	else
		let size = strlen(a:sep)
		let head = strpart(a:text, 0, pos)
		let sep = strpart(a:text, pos, size)
		let tail = strpart(a:text, pos + size)
		return [head, sep, tail]
	endif
endfunc

" replace string
function! s:replace(text, old, new)
	let l:data = split(a:text, a:old, 1)
	return join(l:data, a:new)
endfunc

" load ini file
function! s:readini(source)
	if type(a:source) == type('')
		if !filereadable(a:source)
			return -1
		endif
		let content = readfile(a:source)
	elseif type(a:source) == type([])
		let content = a:source
	else
		return -2
	endif
	let sections = {}
	let current = 'default'
	let index = 0
	for line in content
		let t = substitute(line, '^\s*\(.\{-}\)\s*$', '\1', '')
		let index += 1
		if t == ''
			continue
		elseif t =~ '^[;#].*$'
			continue
		elseif t =~ '^\[.*\]$'
			let current = substitute(t, '^\[\s*\(.\{-}\)\s*\]$', '\1', '')
			if !has_key(sections, current)
				let sections[current] = {}
			endif
		else
			let pos = stridx(t, '=')
			if pos >= 0
				let key = strpart(t, 0, pos)
				let val = strpart(t, pos + 1)
				let key = substitute(key, '^\s*\(.\{-}\)\s*$', '\1', '')
				let val = substitute(val, '^\s*\(.\{-}\)\s*$', '\1', '')
				if !has_key(sections, current)
					let sections[current] = {}
				endif
				let sections[current][key] = val
			endif
		endif
	endfor
	return sections
endfunc

" returns nearest parent directory contains one of the markers
function! s:find_root(name, markers, strict)
	let name = fnamemodify((a:name != '')? a:name : bufname(), ':p')
	let finding = ''
	" iterate all markers
	for marker in split(a:markers, ',')
		if marker != ''
			" search as a file
			let x = findfile(marker, name . '/;')
			let x = (x == '')? '' : fnamemodify(x, ':p:h')
			" search as a directory
			let y = finddir(marker, name . '/;')
			let y = (y == '')? '' : fnamemodify(y, ':p:h:h')
			" which one is the nearest directory ?
			let z = (strchars(x) > strchars(y))? x : y
			" keep the nearest one in finding
			let finding = (strchars(z) > strchars(finding))? z : finding
		endif
	endfor
	if finding == ''
		return (a:strict == 0)? fnamemodify(name, ':h') : ''
	endif
	return fnamemodify(finding, ':p')
endfunc

" find project root
function! s:project_root(name, strict)
	let markers = ['.project', '.git', '.hg', '.svn', '.root']
	if exists('g:asyncrun_rootmarks')
		let markers = g:asyncrun_rootmarks
	endif
	return s:find_root(a:name, markers, a:strict)
endfunc

" change directory in a proper way
function! s:chdir(path)
	if has('nvim')
		let cmd = haslocaldir()? 'lcd' : (haslocaldir(-1, 0)? 'tcd' : 'cd')
	else
		let cmd = haslocaldir()? ((haslocaldir() == 1)? 'lcd' : 'tcd') : 'cd'
	endif
	silent execute cmd . ' '. fnameescape(a:path)
endfunc

" search files upwards
function! s:search_parent(name, cwd)
	let finding = findfile(a:name, a:cwd . '/;', -1)
	let output = []
	for name in finding
		let name = fnamemodify(name, ':p')
		let output += [s:abspath(name)]
	endfor
	return output
endfunc

" get absolute path
function! s:abspath(path)
	let f = a:path
	if f =~ "'."
		try
			redir => m
			silent exe ':marks' f[1]
			redir END
			let f = split(split(m, '\n')[-1])[-1]
			let f = filereadable(f)? f : ''
		catch
			let f = '%'
		endtry
	endif
	let f = (f != '%')? f : expand('%')
	let f = fnamemodify(f, ':p')
	if s:windows != 0
		let f = substitute(f, '\/', '\\', 'g')
	else
		let f = substitute(f, '\\', '\/', 'g')
	endif
	let f = substitute(f, '\\', '\/', 'g')
	if len(f) > 1
		let size = len(f)
		if f[size - 1] == '/'
			let f = strpart(f, 0, size - 1)
		endif
	endif
	return f
endfunc


"----------------------------------------------------------------------
" read ini in cache
"----------------------------------------------------------------------
function! s:cache_load_ini(name)
	let name = (stridx(a:name, '~') >= 0)? expand(a:name) : a:name
	let name = s:abspath(name)
	let p1 = name
	if s:windows || has('win32unix')
		let p1 = tr(tolower(p1), "\\", '/')
	endif
	let ts = getftime(name)
	if ts < 0
		let s:error = 'cannot load ' . a:name
		return -1
	endif
	if has_key(s:private.cache, p1)
		let obj = s:private.cache[p1]
		if ts <= obj.ts
			return obj
		endif
	endif
	let config = s:readini(name)
	if type(config) != v:t_dict
		let s:error = 'syntax error in '. a:name . ' line '. config
		return config
	endif
	let s:private.cache[p1] = {}
	let obj = s:private.cache[p1]
	let obj.ts = ts
	let obj.name = name
	let obj.config = config
	let obj.keys = keys(config)
	let ininame = name
	let inihome = fnamemodify(name, ':h')
	for sect in obj.keys
		let section = obj.config[sect]
		for key in keys(section)
			let val = section[key]
			let val = s:replace(val, '$(VIM_INIHOME)', inihome)
			let val = s:replace(val, '$(VIM_INIFILE)', ininame)
			let section[key] = val
		endfor
	endfor
	return obj
endfunc


"----------------------------------------------------------------------
" check requirement
"----------------------------------------------------------------------
function! s:requirement(what)
	if a:what == 'asyncrun'
		if exists(':AsyncRun') == 0
			let t = 'asyncrun is required, install from '
			call s:errmsg(t . '"skywind3000/asyncrun.vim"')
			return 0
		endif
	endif
	return 1
endfunc


"----------------------------------------------------------------------
" merge two tasks
"----------------------------------------------------------------------
function! s:config_merge(target, source, ininame, mode)
	let special = []
	for key in keys(a:source)
		if stridx(key, ':') >= 0
			let special += [key]
		elseif key != '*'
			let a:target[key] = a:source[key]
			if a:ininame != ''
				let a:target[key].__name__ = a:ininame
			endif
			if a:mode != ''
				let a:target[key].__mode__ = a:mode
			endif
		else
		endif
	endfor
	for key in special
		let parts = s:partition(key, ':')
		if parts[1] != ''
			let profile = s:strip(parts[2])
			if profile == g:asynctasks_profile
				let name = s:strip(parts[0])
				let a:target[name] = a:source[key]
				if a:ininame != ''
					let a:target[name].__name__ = a:ininame
				endif
				if a:mode != ''
					let a:target[name].__mode__ = a:mode
				endif
			endif
		endif
	endfor
	return a:target
endfunc


"----------------------------------------------------------------------
" collect config in rtp
"----------------------------------------------------------------------
function! s:collect_rtp_config() abort
	let names = []
	if g:asynctasks_rtp_config != ''
		let rtp_name = g:asynctasks_rtp_config
		for rtp in split(&rtp, ',')
			if rtp != ''
				let path = s:abspath(rtp . '/' . rtp_name)
				if filereadable(path)
					let names += [path]
				endif
			endif
		endfor
		let t = s:abspath(expand('~/.vim/' . rtp_name))
		if filereadable(t)
			let newname = []
			for name in names
				if name != t
					let newname += [name]
				endif
			endfor
			let names = newname + [t]
		endif
	endif
	for name in g:asynctasks_extra_config
		let name = s:abspath(name)
		if filereadable(name)
			let names += [name]
		endif
	endfor
	let s:private.rtp.ini = {}
	let config = {}
	let s:error = ''
	for name in names
		let obj = s:cache_load_ini(name)
		if s:error == ''
			let mode = 'global'
			call s:config_merge(s:private.rtp.ini, obj.config, name, mode)
		else
			call s:errmsg(s:error)
			let s:error = ''
		endif
	endfor
	let config = deepcopy(s:private.rtp.ini)
	call s:config_merge(config, g:asynctasks_tasks, '<script>', 'script')
	let s:private.rtp.config = config
	return s:private.rtp.config
endfunc


"----------------------------------------------------------------------
" fetch rtp config
"----------------------------------------------------------------------
function! s:compose_rtp_config(force)
	if (!has_key(s:private.rtp, 'config')) || a:force != 0
		call s:collect_rtp_config()
	endif
	return s:private.rtp.config
endfunc


"----------------------------------------------------------------------
" fetch local config
"----------------------------------------------------------------------
function! s:compose_local_config(path)
	let names = s:search_parent(g:asynctasks_config_name, a:path)
	let config = {}
	for name in names
		let s:error = ''
		let obj = s:cache_load_ini(name)
		if s:error == ''
			call s:config_merge(config, obj.config, name, 'local')
		else
			call s:errmsg(s:error)
			let s:error = ''
		endif
	endfor
	let s:private.local.config = config
	return config
endfunc


"----------------------------------------------------------------------
" fetch all config
"----------------------------------------------------------------------
function! asynctasks#collect_config(path, force)
	let path = (a:path == '')? getcwd() : (a:path)
	let s:index = 0
	let s:error = ''
	let c1 = s:compose_rtp_config(a:force)
	let c2 = s:compose_local_config(path)
	let tasks = {'config':{}, 'names':{}, 'avail':[]}
	for cc in [c1, c2]
		call s:config_merge(tasks.config, cc, '', '')
	endfor
	let avail = []
	let modes = {'global':2, 'script':1, 'local':0}
	for key in keys(tasks.config)
		if key != '*'
			let tasks.names[key] = 1
			let avail += [[key, modes[tasks.config[key].__mode__]]]
		endif
	endfor
	call sort(avail)
	for item in avail
		let tasks.avail += [item[0]]
	endfor
	let s:private.tasks = tasks
	return (s:index == 0)? 0 : -1
endfunc


"----------------------------------------------------------------------
" get project root
"----------------------------------------------------------------------
function! asynctasks#project_root(name, ...)
	return s:project_root(a:name, (a:0 == 0)? 0 : (a:1))
endfunc


"----------------------------------------------------------------------
" split section name:system
"----------------------------------------------------------------------
function! asynctasks#split(name)
	let parts = split(name, ':')
	let name = (len(parts) >= 1)? parts[0] : ''
	let system = (len(parts) >= 2)? parts[1] : ''
	let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
	let system = substitute(system, '^\s*\(.\{-}\)\s*$', '\1', '')
	return [name, system]
endfunc


"----------------------------------------------------------------------
" format table
"----------------------------------------------------------------------
function! asynctasks#tabulify(rows)
	let content = []
	let rows = []
	let nrows = len(a:rows)
	let ncols = 0
	for row in a:rows
		if len(row) > ncols
			let ncols = len(row)
		endif
	endfor
	if nrows == 0 || ncols == 0
		return content
	endif
	let sizes = repeat([0], ncols)
	let index = range(ncols)
	for row in a:rows
		let newrow = deepcopy(row)
		if len(newrow) < ncols
			let newrow += repeat([''], ncols - len(newrow))
		endif
		for i in index
			let size = strwidth(newrow[i])
			let sizes[i] = (sizes[i] < size)? size : sizes[i]
		endfor
		let rows += [newrow]
	endfor
	for row in rows
		let ni = []
		for i in index
			let x = row[i]
			let size = strwidth(x)
			if size < sizes[i]
				let x = x . repeat(' ', sizes[i] - size)
			endif
			let ni += [x]
		endfor
		let content += [ni]
	endfor
	return content
endfunc


"----------------------------------------------------------------------
" display table
"----------------------------------------------------------------------
function! s:print_table(rows, highmap)
	let content = asynctasks#tabulify(a:rows)
	let index = 0
	for line in content
		let col = 0
		echon (index == 0)? " " : "\n "
		for cell in line
			let key = index . ',' . col
			if !has_key(a:highmap, key)
				echohl None
			else
				exec 'echohl ' . a:highmap[key]
			endif
			echon cell . '  '
			let col += 1
		endfor
		let index += 1
	endfor
	echohl None
endfunc


"----------------------------------------------------------------------
" extract correct command
"----------------------------------------------------------------------
function! s:command_select(config, ft)
	let command = get(a:config, 'command', '')
	for key in keys(a:config)
		let pos = stridx(key, ':')
		if pos < 0
			continue
		endif
		let part = split(key, ':')
		let head = substitute(part[0], '^\s*\(.\{-}\)\s*$', '\1', '')
		if head != 'command'
			continue
		endif
		let text = substitute(part[1], '^\s*\(.\{-}\)\s*$', '\1', '')
		let check = 0
		for ft in split(text, ',')
			let ft = substitute(ft, '^\s*\(.\{-}\)\s*$', '\1', '')
			if ft == a:ft
				let command = a:config[key]
			endif
		endfor
	endfor
	return command
endfunc


"----------------------------------------------------------------------
" ask user what to do
"----------------------------------------------------------------------
function! s:command_input(command)
	let command = a:command
	let mark_open = '$(?'
	let mark_close = ')'
	let size_open = strlen(mark_open)
	let size_close = strlen(mark_close)
	while 1
		let p1 = stridx(command, mark_open)
		if p1 < 0
			break
		endif
		let p2 = stridx(command, mark_close, p1)
		if p2 < 0
			break
		endif
		let name = strpart(command, p1 + size_open, p2 - p1 - size_open)
		let mark = mark_open . name . mark_close
		echohl Type
		call inputsave()
		try
			let t = input('Input argument (' . name . '): ')
		catch /^Vim:Interrupt$/
			let t = ""
		endtry
		call inputrestore()
		echohl None
		if t == ''
			return ''
		endif
		let command = s:replace(command, mark, t)
	endwhile
	return command
endfunc


"----------------------------------------------------------------------
" format parameter
"----------------------------------------------------------------------
function! s:task_option(task)
	let task = a:task
	let opts = {'mode':''}
	if has_key(task, 'cwd')
		let opts.cwd = task.cwd
	endif
	if has_key(task, 'mode')
		let opts.mode = task.mode
	endif
	if has_key(task, 'raw')
		let opts.raw = task.raw
	endif
	if has_key(task, 'save')
		let opts.save = task.save
	endif
	if has_key(task, 'output')
		let output = task.output
		let opts.mode = 'async'
		if output == 'quickfix'
			let opts.mode = 'async'
		elseif output == 'term' || output == 'terminal'
			let pos = get(a:task, 'pos', g:asynctasks_term_pos)
			let gui = get(g:, 'asyncrun_gui', 0)
			if pos == 'vim' || pos == 'bang'
				let opts.mode = 'bang'
			elseif pos == 'quickfix'
				let opts.mode = 'async'
				let opts.raw = 1
			elseif pos != 'external' && pos != 'system' && pos != 'os'
				let opts.mode = 'term'
				let opts.pos = pos
				let opts.cols = g:asynctasks_term_cols
				let opts.rows = g:asynctasks_term_rows
				let opts.focus = g:asynctasks_term_focus
			elseif s:windows && gui != 0
				let opts.mode = 'system'
			else
				let opts.mode = 'term'
				let opts.pos = 'bottom'
				let opts.cols = g:asynctasks_term_cols
				let opts.rows = g:asynctasks_term_rows
				let opts.focus = g:asynctasks_term_focus
			endif
		elseif output == 'quickfix-raw' || output == 'raw'
			let opts.mode = 'async'
			let opts.raw = 1
		elseif output == 'vim'
			let opts.mode = 'bang'
		endif
	endif
	if has_key(task, 'errorformat')
		let opts.errorformat = task.errorformat
		if task.errorformat == ''
			let opts.raw = 1
		endif
	endif
	if has_key(task, 'strip')
		let opts.strip = task.strip
	endif
	for key in ['pos', 'rows', 'cols', 'focus']
		if has_key(task, key)
			let opts[key] = task[key]
		endif
	endfor
	let opts.safe = 1
	let opts.reuse = g:asynctasks_term_reuse
	if g:asynctasks_term_hidden != 0
		let opts.hidden = 1
	endif
	return opts
endfunc


"----------------------------------------------------------------------
" compare version: 0 for equal, 1 for current > require, -1 for <
"----------------------------------------------------------------------
function! s:version_compare(current, require)
	let current = split(a:current, '\.')
	let require = split(a:require, '\.')
	if len(require) < len(current)
		let require += repeat(['.'], len(current) - len(require))
	elseif len(require) > len(current)
		let current += repeat(['.'], len(require) - len(current))
	endif
	for index in range(len(require))
		let c = str2nr(current[index])
		let r = str2nr(require[index])
		if c > r
			return 1
		elseif c < r
			return -1
		endif
	endfor
	return 0
endfunc


"----------------------------------------------------------------------
" check tool window
"----------------------------------------------------------------------
function! s:command_check(command, cwd)
	let disable = ['FILEPATH', 'FILENAME', 'FILEDIR', 'FILEEXT',
				\ 'FILENOEXT', 'PATHNOEXT', 'RELDIR', 'RELNAME']
	if &bt != ''
		for name in disable
			let macro = '$(VIM_' . name . ')'
			if stridx(a:command, macro) >= 0
				let t = 'task command contains invalid macro'
				call s:errmsg(t . ' in current buffer')
				return 1
			elseif stridx(a:cwd, macro) >= 0
				let t = 'task cwd contains invalid macro'
				call s:errmsg(t . ' in current buffer')
				return 2
			endif
		endfor
	elseif expand('%:p') == ''
		for name in disable
			let macro = '$(VIM_' . name . ')'
			if stridx(a:command, macro) >= 0
				let t = 'macro ' . macro . ' is empty'
				call s:errmsg(t . ' in current buffer')
				return 3
			elseif stridx(a:cwd, macro) >= 0
				let t = 'macro ' . macro . ' is empty'
				call s:errmsg(t . ' in current buffer')
				return 4
			endif
		endfor	
	endif
	return 0
endfunc


"----------------------------------------------------------------------
" run task
"----------------------------------------------------------------------
function! asynctasks#start(bang, taskname, path)
	let path = (a:path == '')? expand('%:p') : a:path
	let path = (path == '')? getcwd() : path
	if asynctasks#collect_config(path, 1) != 0
		return -1
	endif
	let s:error = ''
	let tasks = s:private.tasks
	if !has_key(tasks.names, a:taskname)
		call s:errmsg('not find task [' . a:taskname . ']')
		return -2
	endif
	let task = tasks.config[a:taskname]
	let ininame = task.__name__
	let source = 'task ['. a:taskname . '] from ' . ininame
	let command = s:command_select(task, &ft)
	if command == ''
		call s:errmsg('no command defined in ' . source)
		return -3
	endif
	if exists(':AsyncRun') == 0
		let t = 'asyncrun is required, install from '
		call s:errmsg(t . '"skywind3000/asyncrun.vim"')
		return -4
	endif
	if exists('*asyncrun#version') == 0
		let t = 'asyncrun is too old, get the latest from '
		call s:errmsg(t . '"skywind3000/asyncrun.vim"')
		return -5
	endif
	let target = '2.4.3'
	if s:version_compare(asyncrun#version(), target) < 0
		let t = 'asyncrun ' . target . ' or above is required, update from '
		call s:errmsg(t . '"skywind3000/asyncrun.vim"')
		return -6
	endif
	if s:command_check(command, get(task, 'cwd', '')) != 0
		return -7
	endif
	let command = s:command_input(command)
	if command == ''
		redraw
		echo ""
		redraw
		return 0
	endif
	let opts = s:task_option(task)
	let skip = g:asyncrun_skip
	if opts.mode == 'bang' || opts.mode == 2
		" let g:asyncrun_skip = or(g:asyncrun_skip, 2)
	endif
	call asyncrun#run(a:bang, opts, command)
	let g:asyncrun_skip = skip
	return 0
endfunc


"----------------------------------------------------------------------
" list available tasks
"----------------------------------------------------------------------
function! asynctasks#list(path)
	let path = (a:path == '')? expand('%:p') : a:path
	let path = (path == '')? getcwd() : path
	if asynctasks#collect_config(path, 1) != 0
		return -1
	endif
	let tasks = s:private.tasks
	let rows = []
	for task in tasks.avail
		let item = tasks.config[task]
		let command = get(item, 'command', '')
		let ni = {}
		let ni.name = task
		let ni.command = s:command_select(item, &ft)
		let ni.scope = item.__mode__
		let ni.source = item.__name__
		if ni.command != ''
			let rows += [ni]
		endif
	endfor
	return rows
endfunc


"----------------------------------------------------------------------
" list tasks
"----------------------------------------------------------------------
function! s:task_list(path, showall)
	let path = (a:path == '')? expand('%:p') : a:path
	let path = (path == '')? getcwd() : path
	if asynctasks#collect_config(path, 1) != 0
		return -1
	endif
	let tasks = s:private.tasks
	let rows = []
	let rows += [['Task', 'Type', 'Detail']]
	let highmap = {}
	let index = 0
	let highmap['0,0'] = 'Title'
	let highmap['0,1'] = 'Title'
	let highmap['0,2'] = 'Title'
	" let rows += [['----', '----', '------']]
	for task in tasks.avail
		if a:showall == 0
			if strpart(task, 0, 1) == '.'
				continue
			endif
		endif
		let item = tasks.config[task]
		let command = s:command_select(item, &ft)
		if command != ''
			let rows += [[task, item.__mode__, command]]
			let rows += [['', '', item.__name__]]
		endif
		let highmap[(index * 2 + 1) . ',0'] = 'Keyword'
		let highmap[(index * 2 + 1) . ',1'] = 'Number'
		let highmap[(index * 2 + 1) . ',2'] = 'Statement'
		let highmap[(index * 2 + 2) . ',2'] = 'Comment'
		let index += 1
	endfor
	call s:print_table(rows, highmap)
	" echo highmap
endfunc


"----------------------------------------------------------------------
" config template
"----------------------------------------------------------------------
let s:template = [
	\ '# vim: set fenc=utf-8 ft=dosini:',
	\ '',
	\ '# define a new task named "file-build"',
	\ '[file-build]',
	\ '',
	\ '# shell command, use quotation for filenames containing spaces',
	\ '# check ":AsyncTaskMacro" to see available macros',
	\ 'command=gcc "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)"',
	\ '',
	\ '# working directory, can change to $(VIM_ROOT) for project root',
	\ 'cwd=$(VIM_FILEDIR)',
	\ '',
	\ '# output mode, can be one of quickfix and terminal',
	\ '# - quickfix: output to quickfix window',
	\ '# - terminal: run the command in the internal terminal',
	\ 'output=quickfix',
	\ '',
	\ '# this is for output=quickfix only',
	\ "# if it is omitted, vim's current errorformat will be used.",
	\ 'errorformat=%f:%l:%m',
	\ '',
	\ '# save file before execute',
	\ 'save=1',
	\ '',
	\ ]


"----------------------------------------------------------------------
" edit task
"----------------------------------------------------------------------
function! s:task_edit(mode, path)
	let name = a:path
	if s:requirement('asyncrun') == 0
		return -1
	endif
	if name == ''
		if a:mode ==# '-e'
			let name = asyncrun#get_root('%')
			let name = name . '/' . g:asynctasks_config_name
			let name = fnamemodify(expand(name), ':p')
		else
			let name = expand('~/.vim/' . g:asynctasks_rtp_config)
		endif
	endif
	call inputsave()
	let r = input('(Edit task config): ', name)
	call inputrestore()
	if r == ''
		return -1
	endif
	let newfile = filereadable(name)? 0 : 1
	exec "split " . fnameescape(name)
	setlocal ft=dosini
	if newfile
		exec "normal ggVGx"
		call append(line('.') - 1, s:template)
		setlocal nomodified
	endif
endfunc


"----------------------------------------------------------------------
" macro help 
"----------------------------------------------------------------------
let s:macros = { 
	\ 'VIM_FILEPATH': 'File name of current buffer with full path',
	\ 'VIM_FILENAME': 'File name of current buffer without path',
	\ 'VIM_FILEDIR': 'Full path of current buffer without the file name',
	\ 'VIM_FILEEXT': 'File extension of current buffer',
	\ 'VIM_FILETYPE': 'File type (value of &ft in vim)',
	\ 'VIM_FILENOEXT': 
		\ 'File name of current buffer without path and extension',
	\ 'VIM_PATHNOEXT':
		\ 'Current file name with full path but without extension',
	\ 'VIM_CWD': 'Current directory',
	\ 'VIM_RELDIR': 'File path relativize to current directory',
	\ 'VIM_RELNAME': 'File name relativize to current directory',
	\ 'VIM_ROOT': 'Project root directory',
	\ 'VIM_PRONAME': 'Name of current project root directory',
	\ 'VIM_DIRNAME': "Name of current directory",
	\ 'VIM_CWORD': 'Current word under cursor',
	\ 'VIM_CFILE': 'Current filename under cursor',
	\ 'VIM_CLINE': 'Cursor line number in current buffer',
	\ 'VIM_GUI': 'Is running under gui ?',
	\ 'VIM_VERSION': 'Value of v:version',
	\ 'VIM_COLUMNS': "How many columns in vim's screen",
	\ 'VIM_LINES': "How many lines in vim's screen", 
	\ 'VIM_SVRNAME': 'Value of v:servername for +clientserver usage',
	\ }


"----------------------------------------------------------------------
" expand macros
"----------------------------------------------------------------------
function! s:expand_macros()
	let macros = {}
	let macros['VIM_FILEPATH'] = expand("%:p")
	let macros['VIM_FILENAME'] = expand("%:t")
	let macros['VIM_FILEDIR'] = expand("%:p:h")
	let macros['VIM_FILENOEXT'] = expand("%:t:r")
	let macros['VIM_PATHNOEXT'] = expand("%:r")
	let macros['VIM_FILEEXT'] = "." . expand("%:e")
	let macros['VIM_FILETYPE'] = (&filetype)
	let macros['VIM_CWD'] = getcwd()
	let macros['VIM_RELDIR'] = expand("%:h:.")
	let macros['VIM_RELNAME'] = expand("%:p:.")
	let macros['VIM_CWORD'] = expand("<cword>")
	let macros['VIM_CFILE'] = expand("<cfile>")
	let macros['VIM_CLINE'] = line('.')
	let macros['VIM_VERSION'] = ''.v:version
	let macros['VIM_SVRNAME'] = v:servername
	let macros['VIM_COLUMNS'] = ''.&columns
	let macros['VIM_LINES'] = ''.&lines
	let macros['VIM_GUI'] = has('gui_running')? 1 : 0
	let macros['VIM_ROOT'] = asyncrun#get_root('%')
    let macros['VIM_HOME'] = expand(split(&rtp, ',')[0])
	let macros['VIM_PRONAME'] = fnamemodify(macros['VIM_ROOT'], ':t')
	let macros['VIM_DIRNAME'] = fnamemodify(macros['VIM_CWD'], ':t')
	let macros['<cwd>'] = macros['VIM_CWD']
	let macros['<root>'] = macros['VIM_ROOT']
	if expand("%:e") == ''
		let macros['VIM_FILEEXT'] = ''
	endif
	return macros
endfunc


"----------------------------------------------------------------------
" macro list
"----------------------------------------------------------------------
function! s:task_macro()
	let macros = s:expand_macros()
	let names = ['FILEPATH', 'FILENAME', 'FILEDIR', 'FILEEXT', 'FILETYPE']
	let names += ['FILENOEXT', 'PATHNOEXT', 'CWD', 'RELDIR', 'RELNAME']
	let names += ['CWORD', 'CFILE', 'CLINE', 'VERSION', 'SVRNAME', 'COLUMNS']
	let names += ['LINES', 'GUI', 'ROOT', 'DIRNAME', 'PRONAME']
	let rows = []
	let rows += [['Macro', 'Detail', 'Value']]
	let highmap = {}
	let highmap['0,0'] = 'Title'
	let highmap['0,1'] = 'Title'
	let highmap['0,2'] = 'Title'
	let index = 1
	if &bt != ''
		let disable = ['FILEPATH', 'FILENAME', 'FILEDIR', 'FILEEXT',
					\ 'FILENOEXT', 'PATHNOEXT', 'RELDIR', 'RELNAME']
		for nn in disable
			let name = 'VIM_' . nn
			let macros[name] = '<invalid>'
		endfor
	endif
	for nn in names
		let name = 'VIM_' . nn
		let rows += [['$(' . name . ')', s:macros[name], macros[name]]]
		" let rows += [['', macros[name]]]
		let highmap[index . ',0'] = 'Keyword'
		let highmap[index . ',1'] = 'Statement'
		let highmap[index . ',2'] = 'Comment'
		let index += 1
	endfor
	call s:print_table(rows, highmap)
endfunc


"----------------------------------------------------------------------
" command AsyncTask
"----------------------------------------------------------------------
function! asynctasks#cmd(bang, ...)
	let taskname = (a:0 >= 1)? (a:1) : ''
	let path = (a:0 >= 2)? (a:2) : ''
	if taskname == ''
		call s:errmsg('require task name, use :AsyncTask -h for help')
		return -1
	elseif taskname == '-h'
		echo 'usage:  :AsyncTask <operation>'
		echo 'operations:'
		echo '    :AsyncTask {taskname}      - run specific task'
		echo '    :AsyncTask -l              - list tasks (use -L to list all)'
		echo '    :AsyncTask -h              - show this help'
		echo '    :AsyncTask -e              - edit local task in project root'
		echo '    :AsyncTask -E              - edit global task in ~/.vim'
		echo '    :AsyncTask -m              - display command macros'
		echo '    :AsyncTask -p <profile>    - switch current profile'
		return 0
	elseif taskname ==# '-l'
		call s:task_list('', 0)
		return 0
	elseif taskname ==# '-L'
		call s:task_list('', 1)
		return 0
	elseif taskname ==# '-e' || taskname ==# '-E'
		call s:task_edit(taskname, path)
		return 0
	elseif taskname == '-m'
		call s:task_macro()
		return 0
	elseif taskname == '-p'
		let profile = (a:0 >= 2)? (a:2) : ''
		if profile != ''
			let g:asynctasks_profile = profile
		endif
		echohl Number
		echo 'Current profile: '. g:asynctasks_profile
		echohl None
		return 0
	endif
	call asynctasks#start(a:bang, taskname, '')
endfunc


"----------------------------------------------------------------------
" command
"----------------------------------------------------------------------

command! -bang -nargs=* AsyncTask
			\ call asynctasks#cmd('<bang>', <f-args>)


"----------------------------------------------------------------------
" help commands
"----------------------------------------------------------------------
command! -bang -nargs=0 AsyncTaskEdit
			\ call asynctasks#cmd('', ('<bang>' == '')? '-e' : '-E')

command! -bang -nargs=0 AsyncTaskList 
			\ call asynctasks#cmd('', ('<bang>' == '')? '-l' : '-L')

command! -nargs=0 AsyncTaskMacro
			\ call asynctasks#cmd('', '-m')

command! -nargs=? AsyncTaskProfile
			\ call asynctasks#cmd('', '-p', <f-args>)


"----------------------------------------------------------------------
" benchmark
"----------------------------------------------------------------------
function! asynctasks#timing()
	let ts = reltime()
	" call s:collect_rtp_config()
	call asynctasks#collect_config('.', 1)
	let tt = reltimestr(reltime(ts))
	echo s:private.rtp.config
	return tt
endfunc


