local function get_indent_size()
  if vim.bo.shiftwidth > 0 and vim.bo.expandtab then
    return vim.bo.shiftwidth
  end
  return vim.bo.tabstop
end

local indent_size = get_indent_size()

local mark = vim.api.nvim_buf_set_extmark
local ns = vim.api.nvim_create_namespace("indent_line")
vim.cmd[[highlight indent_line guifg=none gui=nocombine]]

local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

for i, v in ipairs(lines) do
  if #v == 0 then
    return
  end

  local indent = { "|", "IndentBlanklineChar" }
  local blank = { "|", "IndentBlanklineChar" }
  local guides = {}
  local n = math.floor(vim.fn.cindent(i)) - 1
  local j = indent_size

  while n > 0 do
    guides[#guides+1] = indent
    while j > 0 do
      guides[#guides+1] = blank
      j = j - 1
    end
    n = n - 1
  end
  mark(0, ns, i, 0, { virt_text = guides, virt_text_pos = 'overlay' })

end
