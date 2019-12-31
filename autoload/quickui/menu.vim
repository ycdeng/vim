"======================================================================
"
" menu.vim - main menu bar
"
" Created by skywind on 2019/12/24
" Last Modified: 2019/12/30 01:14
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :


"----------------------------------------------------------------------
" namespace of configuration
"----------------------------------------------------------------------
let s:namespace = { 'system':{'config':{}, 'weight':100, 'index':0} }
let s:name = 'system'


"----------------------------------------------------------------------
" switch config namespace
"----------------------------------------------------------------------
function! quickui#menu#switch(name)
	if !has_key(s:namespace, a:name)
		let s:namespace[a:name] = {}
		let s:namespace[a:name].config = {}
		let s:namespace[a:name].index = 0
		let s:namespace[a:name].weight = 100
	endif
	let s:name = a:name
endfunc


"----------------------------------------------------------------------
" clear all entries in current namespace
"----------------------------------------------------------------------
function! quickui#menu#reset()
	let current = s:namespace[s:name].config
	let s:namespace[s:name].weight = 100
	let s:namespace[s:name].index = 0
	for key in keys(current)
		call remove(current, key)
	endfor
endfunc


"----------------------------------------------------------------------
" register entry: (section='File', entry='&Save', command='w')
"----------------------------------------------------------------------
function! quickui#menu#register(section, entry, command, help)
	let current = s:namespace[s:name].config
	if !has_key(current, a:section)
		let index = 0
		let maximum = 0
		for name in keys(current)
			let w = current[name].weight
			let maximum = (index == 0)? w : ((maximum < w)? w : maximum)
			let index += 1
		endfor
		let current[a:section] = {'name':a:section, 'weight':0, 'items':[]}
		let current[a:section].weight = s:namespace[s:name].weight
		let s:namespace[s:name].weight += 10
	endif
	let menu = current[a:section]
	let item = {'name':a:entry, 'cmd':a:command, 'help':a:help}
	let menu.items += [item]
endfunc


"----------------------------------------------------------------------
" remove entry:
"----------------------------------------------------------------------
function! quickui#menu#remove(section, index)
	let current = s:namespace[s:name].config
	if !has_key(current, a:section)
		return -1
	endif
	let menu = current[a:section]
	if type(a:index) == v:t_number
		let index = (a:index < 0)? (len(menu.items) + a:index) : a:index
		if index < 0 || index >= len(menu.items)
			return -1
		endif
		call remove(menu.items, index)
	elseif type(a:index) == v:t_string
		if a:index ==# '*'
			menu.items = []
		else
			let index = -1
			for ii in range(len(menu.items))
				if menu.items[ii].name ==# a:index
					let index = ii
					break
				endif
			endfor
			if index < 0 
				return -1
			endif
			call remove(menu.items, index)
		endif
	endif
	return 0
endfunc


"----------------------------------------------------------------------
" return items key 
"----------------------------------------------------------------------
function! quickui#menu#section(section)
	let current = s:namespace[s:name].config
	return get(current, a:section, v:null)
endfunc


"----------------------------------------------------------------------
" install a how section
"----------------------------------------------------------------------
function! quickui#menu#install(section, content, ...)
	let current = s:namespace[s:name].config
	if type(a:content) == v:t_list
		for item in a:content
			if type(item) == v:t_dict
				call quickui#menu#register(a:section, item.name, item.command)
			elseif type(item) == v:t_list
				let size = len(item)
				let name = (size >= 1)? item[0] : ''
				let cmd = (size >= 2)? item[1] : ''
				let help = (size >= 3)? item[2] : ''
				call quickui#menu#register(a:section, name, cmd, help)
			elseif type(item) == v:t_string
				call quickui#menu#register(a:section, item, '', '')
			endif
		endfor
	elseif type(a:content) == v:t_dict
		for name in keys(a:content)
			let cmd = a:content[name]
			call quickui#menu#register(a:section, name, cmd, '')
		endfor
	endif
	if a:0 > 0 && has_key(current, a:section)
		let current[a:section].weight = a:1
	endif
endfunc


"----------------------------------------------------------------------
" change weight
"----------------------------------------------------------------------
function! quickui#menu#change_weight(section, weight)
	let current = s:namespace[s:name].config
	if has_key(current, a:section)
		let current[a:section].weight = a:weight
	endif
endfunc


"----------------------------------------------------------------------
" preset menu
"----------------------------------------------------------------------
function! quickui#menu#preset(section, context, ...)
	let current = s:namespace[s:name].config
	let save_items = []
	if has_key(current, a:section)
		let save_items = current[a:section].items
		let current[a:section].items = []
	endif
	if a:0 == 0
		call quickui#menu#install(a:section, a:context)
	else
		call quickui#menu#install(a:section, a:context, a:1)
	endif
	if len(save_items) > 0
		if len(a:context) > 0
			call quickui#menu#register(a:section, '--', '', '')
		endif
		for ni in save_items
			call quickui#menu#register(a:section, ni.name, ni.cmd, ni.help)
		endfor
	endif
endfunc


"----------------------------------------------------------------------
" compare section
"----------------------------------------------------------------------
function! s:section_compare(s1, s2)
	if a:s1[0] == a:s2[0]
		return 0
	else
		return (a:s1[0] > a:s2[0])? 1 : -1
	endif
endfunc


"----------------------------------------------------------------------
" get section
"----------------------------------------------------------------------
function! quickui#menu#available(name)
	let current = s:namespace[a:name].config
	let menus = []
	for name in keys(current)
		let menu = current[name]
		if len(menu.items) > 0
			let menus += [[menu.weight, menu.name]]
		endif
	endfor
	call sort(menus, 's:section_compare')
	let result = []
	for obj in menus
		let result += [obj[1]]
	endfor
	return result
endfunc


"----------------------------------------------------------------------
" parse
"----------------------------------------------------------------------
function! s:parse_menu(name)
	let current = s:namespace[a:name].config
	let inst = {'items':[], 'text':'', 'width':0, 'hotkey':{}}
	let start = 0
	let split = '  '
	let names = quickui#menu#available(a:name)
	let index = 0
	let size = len(names)
	for section in names
		let menu = current[section]
		let item = {'name':menu.name, 'text':''}
		let obj = quickui#core#escape(menu.name)
		let item.text = ' ' . obj[0] . ' '
		let item.key_char = obj[1]
		let item.key_pos = (obj[4] < 0)? -1 : (obj[4] + 1)
		let item.x = start
		let item.w = strwidth(item.text)
		let start += item.w + strwidth(split)
		let inst.items += [item]
		let inst.text .= item.text . ((index + 1 < size)? split : '')
		let inst.width += item.w
		if item.key_pos >= 0
			let key = tolower(item.key_char)
			let inst.hotkey[key] = index
		endif
		let index += 1
	endfor
	return inst
endfunc


"----------------------------------------------------------------------
" internal
"----------------------------------------------------------------------
let s:cmenu = {'state':0, 'index':0, 'size':0, 'winid':-1, 'drop':-1}


"----------------------------------------------------------------------
" create popup ui
"----------------------------------------------------------------------
function! quickui#menu#create(opts)
	if s:cmenu.state != 0
		return -1
	endif
	let name = get(a:opts, 'name', s:name)
	if !has_key(s:namespace, name)
		return -1
	endif
	let current = s:namespace[name].config
	let s:cmenu.inst = s:parse_menu(name)
	let s:cmenu.name = name
	let s:cmenu.index = s:namespace[name].index
	let s:cmenu.width = &columns
	let s:cmenu.size = len(s:cmenu.inst.items)
	let s:cmenu.current = current
	let winid = popup_create([s:cmenu.inst.text], {'hidden':1, 'wrap':0})
	let bufnr = winbufnr(winid)
	let s:cmenu.winid = winid
	let s:cmenu.bufnr = bufnr
	let s:cmenu.cfg = deepcopy(a:opts)
	let w = s:cmenu.width
	let opts = {"minwidth":w, "maxwidth":w, "minheight":1, "maxheight":1}
	let opts.line = 1
	let opts.col = 1
	call popup_move(winid, opts)
	call setwinvar(winid, '&wincolor', get(a:opts, 'color', 'QuickBG'))
	let opts = {'mapping':0, 'cursorline':0, 'drag':0, 'zindex':31000}
	let opts.border = [0,0,0,0,0,0,0,0,0]
	let opts.padding = [0,0,0,0]
	let opts.filter = 'quickui#menu#filter'
	let opts.callback = 'quickui#menu#callback'
	if 1
		let keymap = quickui#utils#keymap()
		let s:cmenu.keymap = keymap
		let keymap['H'] = 'LEFT'
		let keymap['L'] = 'RIGHT'
	endif
	let s:cmenu.hotkey = s:cmenu.inst.hotkey
	" echo "hotkey: ". string(s:cmenu.hotkey)
	let s:cmenu.drop = -1
	let s:cmenu.state = 1
	let s:cmenu.context = -1
	call popup_setoptions(winid, opts)
	call quickui#menu#update()
	call popup_show(winid)
	return 0
endfunc


"----------------------------------------------------------------------
" render menu
"----------------------------------------------------------------------
function! quickui#menu#update()
	let winid = s:cmenu.winid
	if s:cmenu.state == 0
		return -1
	endif
	let inst = s:cmenu.inst
	call win_execute(winid, "syn clear")
	let index = 0
	for item in inst.items
		if item.key_pos >= 0
			let x = item.key_pos + item.x + 1
			let cmd = quickui#core#high_region('QuickKey', 1, x, 1, x + 1, 1)
			call win_execute(winid, cmd)
		endif
		let index += 1
	endfor
	let index = s:cmenu.index
	if index >= 0 && index < s:cmenu.size
		let x = inst.items[index].x + 1
		let e = x + inst.items[index].w
		let cmd = quickui#core#high_region('QuickSel', 1, x, 1, e, 1)
		call win_execute(winid, cmd)
	endif
	return 0
endfunc


"----------------------------------------------------------------------
" close menu
"----------------------------------------------------------------------
function! quickui#menu#close()
	if s:cmenu.state != 0
		call popup_close(s:cmenu.winid)
		let s:cmenu.winid = -1
		let s:cmenu.state = 0
	endif
endfunc



"----------------------------------------------------------------------
" exit callback
"----------------------------------------------------------------------
function! quickui#menu#callback(winid, code)
	" echom "quickui#menu#callback"
	let s:cmenu.state = 0
	let s:cmenu.winid = -1
	let s:namespace[s:cmenu.name].index = s:cmenu.index
	if s:cmenu.context >= 0
		call popup_close(s:cmenu.context, -3)
		let s:cmenu.context = -1
	endif
endfunc


"----------------------------------------------------------------------
" event handler
"----------------------------------------------------------------------
function! quickui#menu#filter(winid, key)
	let keymap = s:cmenu.keymap
	if a:key == "\<ESC>" || a:key == "\<c-c>"
		call popup_close(a:winid, -1)
		return 1
	elseif a:key == "\<LeftMouse>"
		return s:mouse_click()
	elseif has_key(s:cmenu.hotkey, a:key)
		let index = s:cmenu.hotkey[a:key]
		let index = (index < 0)? (s:cmenu.size - 1) : index
		let index = (index >= s:cmenu.size)? 0 : index
		let s:cmenu.index = (s:cmenu.size == 0)? 0 : index
		call quickui#menu#update()
		call s:context_dropdown()
		redraw
	elseif has_key(keymap, a:key)
		let key = keymap[a:key]
		call s:movement(key)
		redraw
		return 1
	endif
	return 1
endfunc


"----------------------------------------------------------------------
" moving 
"----------------------------------------------------------------------
function! s:movement(key)
	if a:key == 'ESC'
		call popup_close(a:winid, -1)
		return 1
	elseif a:key == 'LEFT' || a:key == 'RIGHT'
		let index = s:cmenu.index
		if index < 0
			let index = 0
		elseif a:key == 'LEFT'
			let index -= 1
		elseif a:key == 'RIGHT'
			let index += 1
		endif
		let index = (index < 0)? (s:cmenu.size - 1) : index
		let index = (index >= s:cmenu.size)? 0 : index
		let s:cmenu.index = (s:cmenu.size == 0)? 0 : index
		call quickui#menu#update()
		" echo "MOVE: " . index
	elseif a:key == 'ENTER' || a:key == 'DOWN'
		call s:context_dropdown()
	endif
endfunc


"----------------------------------------------------------------------
" mouse click
"----------------------------------------------------------------------
function! s:mouse_click()
	let pos = getmousepos()
	if pos.winid != s:cmenu.winid || pos.line != 1
		call popup_close(s:cmenu.winid, -1)
		return 0
	endif
	let x = pos.wincol - 1
	let index = 0
	let select = -1
	for item in s:cmenu.inst.items
		if x >= item.x && x < item.x + item.w
			let select = index
		endif
		let index += 1
	endfor
	if select >= 0
		let s:cmenu.index = select
		if s:cmenu.context >= 0
			call popup_close(s:cmenu.index, -1)
			let s:cmenu.context = -1
		endif
		call quickui#menu#update()
		call s:context_dropdown()
		redraw
	endif
	return 1
endfunc


"----------------------------------------------------------------------
" drop down context
"----------------------------------------------------------------------
function! s:context_dropdown()
	let cursor = s:cmenu.index
	if cursor < 0 || cursor >= s:cmenu.size || s:cmenu.state == 0
		return 0
	endif
	if s:cmenu.state == 2
		call popup_close(s:cmenu.context, -3)
		let s:cmenu.state = 1
		let s:cmenu.context = -1
	endif
	let item = s:cmenu.inst.items[s:cmenu.index]
	let opts = {'col': item.x + 1, 'line': 2, 'horizon':1, 'zindex':31100}
	let opts.callback = 'quickui#menu#context_exit'
	let opts.reserve = 1
	let cfg = s:cmenu.current[item.name]
	let s:cmenu.dropdown = []
	for item in cfg.items
		let s:cmenu.dropdown += [[item.name, item.cmd, item.help]]
	endfor
	let index = get(cfg, 'index', 0)
	let opts.index = (index < 0 || index >= len(cfg.items))? 0 : index
	let cfg.index = opts.index
	let hwnd = quickui#context#create(s:cmenu.dropdown, opts)
	let s:cmenu.context = hwnd.winid
	let s:cmenu.state = 1
endfunc


"----------------------------------------------------------------------
" context menu callback
"----------------------------------------------------------------------
function! quickui#menu#context_exit(code)
	" echom "quickui#menu#context_exit"
	let s:cmenu.context = -1
	let hwnd = g:quickui#context#current
	if has_key(hwnd, 'index') && hwnd.index >= 0
		let item = s:cmenu.inst.items[s:cmenu.index]
		let cfg = s:cmenu.current[item.name]
		let cfg.index = hwnd.index
		" echo "save index: ".hwnd.index
	endif
	if a:code >= 0 || a:code == -3
		if s:cmenu.state > 0 && s:cmenu.winid >= 0
			call popup_close(s:cmenu.winid, 0)
		endif
		return 0
	elseif a:code == -1		" close context menu by ESC
		if s:cmenu.state > 0 && s:cmenu.winid >= 0
			call popup_close(s:cmenu.winid, 0)
		endif
	elseif a:code == -2     " close context menu by mouse
		if s:cmenu.state > 0 && s:cmenu.winid >= 0
			let pos = getmousepos()
			if pos.winid != s:cmenu.winid
				call popup_close(s:cmenu.winid, 0)
			endif
		endif
	elseif a:code == -1000 || a:code == -2000
		call s:movement((a:code == -1000)? 'LEFT' : 'RIGHT')
		call s:movement('DOWN')
	endif
	return 0
endfunc


"----------------------------------------------------------------------
" open menu
"----------------------------------------------------------------------
function! quickui#menu#open(...)
	let opts = {}
	if a:0 > 0
		let opts.name = a:1
	endif
	call quickui#menu#create(opts)
endfunc


"----------------------------------------------------------------------
" testing suit
"----------------------------------------------------------------------
if 0
	call quickui#menu#switch('test')
	call quickui#menu#reset()
	call quickui#menu#install('H&elp', [
				\ [ '&Content', 'echo 4' ],
				\ [ '&About', 'echo 5' ],
				\ ])
	call quickui#menu#install('&File', [
				\ [ "&New File\tCtrl+n", '' ],
				\ [ "&Open File\t(F3)", 'echo 1' ],
				\ [ "&Close", 'echo 3' ],
				\ [ "--", '' ],
				\ [ "&Save\tCtrl+s", ''],
				\ [ "Save &As", '' ],
				\ [ "Save All", '' ],
				\ [ "--", '' ],
				\ [ "E&xit\tAlt+x", '' ],
				\ ])
	call quickui#menu#install('&Edit', [
				\ [ '&Copy', 'echo 1', 'help1' ],
				\ [ '&Paste', 'echo 2', 'help2' ],
				\ [ '&Find', 'echo 3', 'help3' ],
				\ ])
	call quickui#menu#install('&Tools', [
				\ [ '&Copy', 'echo 1', 'help1' ],
				\ [ '&Paste', 'echo 2', 'help2' ],
				\ [ '&Find', 'echo 3', 'help3' ],
				\ ])

	call quickui#menu#install('&Window', [])
	call quickui#menu#change_weight('H&elp', 1000)
	call quickui#menu#switch('system')
	call quickui#menu#open('test')
endif



