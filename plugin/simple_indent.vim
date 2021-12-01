augroup simple_indent
	au!
	au TextChanged * lua require('simple_indent').refresh()
	au TextChangedI * lua require('simple_indent').refresh_lines()
	au InsertLeave * let g:simple_indent_last_line = 0
	au BufReadPost * lua require('simple_indent').enable()
augroup END
