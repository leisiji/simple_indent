local indent = { '|', 'IndentChar' }
local blank = { ' ', 'IndentChar' }
local ns = vim.api.nvim_create_namespace("indent_guides")
local fn = vim.fn
local clear = vim.api.nvim_buf_clear_namespace
local M = {}
local ex = {'', 'help', 'fzf', 'FTerm', 'NvimTree'}
local refresh_timer = nil
local max_line = 10000
vim.g.simple_indent_last_line = 0

local function init_hi()
  local hi = fn.synIDtrans(fn.hlID("Whitespace"))
  local fg = fn.synIDattr(hi, "fg", "gui")
  local cmd = string.format('hi IndentChar guifg=%s gui=nocombine', fg)
  vim.cmd(cmd)
end

local function get_indent_size()
  if vim.bo.shiftwidth > 0 and vim.bo.expandtab then
    return vim.bo.shiftwidth
  end
  return vim.bo.tabstop
end

local function mark(row, col, guides)
  vim.api.nvim_buf_set_extmark(0, ns, row, col,
    { virt_text = guides, virt_text_pos = 'overlay', hl_mode = 'combine' }
  )
end

local function gen_guides(len)
  local g = {}
  g[1] = indent
  for i = 1, len - 1, 1 do
    g[i+1] = blank
  end
  return g
end

local function get_char(str, i)
  return string.sub(str, i, i)
end

local function get_lead_tab(str)
  local lead = 0
  for i = 1, #str, 1 do
    if get_char(str, i) == '\t' then
      lead = lead + 1
    else
      break
    end
  end
  if get_char(str, lead + 1) ~= ' ' then
    lead = -1
  end
  return lead
end

local function create_mark(idt_size, ln, line, guide)
  local st
  local lead_tab = get_lead_tab(line)

  if lead_tab ~= 0 then
    st = lead_tab + 1
  elseif lead_tab == -1 then -- tab only line
    return
  else
    for i = 1, idt_size, 1 do
      if get_char(line, i) ~= ' ' then
        return
      end
    end
    st = idt_size + 1
  end

  local guides = {}
  local cnt = 0

  for i = st, #line, 1 do
    local s = get_char(line, i)
    if s == ' ' then
      cnt = cnt + 1
      if cnt == idt_size then
        guides = fn.extend(guides, guide)
        cnt = 0
      end
    else
      break
    end
  end

  if cnt > 0 then
    guides = fn.extend(guides, gen_guides(cnt))
  end

  if #guides ~= 0 then
    mark(ln - 1, st - 1, guides)
  end
end

local function create_line_mark(st, ed)
  coroutine.wrap(function ()
    local lines = vim.api.nvim_buf_get_lines(0, st, ed, false)
    local idt_size = get_indent_size()
    local guide = gen_guides(idt_size)
    for i, line in pairs(lines) do
      if #line ~= 0 then
        create_mark(idt_size, i+st, line, guide)
      end
    end
  end)()
end

local function enable_indent_guides_()
  create_line_mark(0, -1)
end

local function disabled()
  if fn.index(ex, vim.bo.filetype) ~= -1 or fn.line('$') > max_line then
    return true
  end
  return false
end

function M.enable()
  if disabled() then
    return
  end
  enable_indent_guides_()
  vim.cmd[[
    augroup simple_indent_buffer
        au! * <buffer>
        au TextChanged <buffer> lua require('simple_indent').refresh()
        au TextChangedI <buffer> lua require('simple_indent').refresh_lines()
    augroup END
  ]]
end

function M.disable()
  clear(0, ns, 0, -1)
  vim.cmd[[augroup! simple_indent]]
end

function M.refresh()
  -- Some plugin may not set &ft at first, remove it later
  if disabled() then
    return
  end

  clear(0, ns, 0, -1)
  enable_indent_guides_()
end

function M.refresh_lines()
  if refresh_timer ~= nil then
    vim.loop.timer_stop(refresh_timer)
    refresh_timer = nil
  end
  refresh_timer = vim.defer_fn(function ()
    local ln = fn.line('.')
    local start = ln - 1
    local last_line = vim.g.simple_indent_last_line
    if last_line ~= 0 then
      start = last_line - 1
    end
    clear(0, ns, start, ln)
    create_line_mark(start, ln)
    vim.g.simple_indent_last_line = ln
  end, 100)
end

init_hi()

return M
