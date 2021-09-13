local function get_indent_size()
  if vim.bo.shiftwidth > 0 and vim.bo.expandtab then
    return vim.bo.shiftwidth
  end
  return vim.bo.tabstop
end

local indent = { '|', 'IndentBlanklineChar' }
local blank = { ' ', '' }

local mark = vim.api.nvim_buf_set_extmark
local ns = vim.api.nvim_create_namespace("indent_guides")
vim.cmd[[highlight indent_line guifg=none guibg=none]]

local M = {}

local function create_mark(idt_size, ln)
  local guides = {}
  local idt = vim.fn.indent(ln)
  if idt > 0 then
    local n = math.floor(idt / idt_size)
    print(ln, n)
    if n > 1 then
      for _ = 1, n - 1, 1 do
        guides[#guides+1] = indent
        for _ = 1, idt_size - 1, 1 do
          guides[#guides+1] = blank
        end
      end

      mark(0, ns, ln - 1, idt_size, { virt_text = guides, virt_text_pos = 'overlay' })
    end
  end
end

function M.enable_indent_guides()
 local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
 local idt_size = get_indent_size()
  for i, v in pairs(lines) do
    if #v ~= 0 then
      create_mark(idt_size, i)
    end
  end
end

M.enable_indent_guides()

return M
