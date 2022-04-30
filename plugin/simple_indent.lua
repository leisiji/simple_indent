local group = "simple_indent"
local a = vim.api

a.nvim_create_augroup("simple_indent_buffer", { clear = true })
a.nvim_create_augroup(group, { clear = true })

a.nvim_create_autocmd({ "InsertLeave" }, {
  group = group,
  callback = function()
    vim.g.simple_indent_last_line = 0
  end,
})
a.nvim_create_autocmd({ "BufReadPost" }, { group = group, callback = require("simple_indent").enable })
