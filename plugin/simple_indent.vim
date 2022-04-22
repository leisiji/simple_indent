augroup simple_indent
	au!
	au InsertLeave * let g:simple_indent_last_line = 0
	au BufReadPost * lua require('simple_indent').enable()
augroup END
