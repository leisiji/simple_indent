augroup simple_indent
	au!
	au BufReadPost * lua require('simple_indent').enable()
augroup END
