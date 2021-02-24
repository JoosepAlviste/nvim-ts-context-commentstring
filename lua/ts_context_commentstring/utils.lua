local api = vim.api
local cmd = vim.cmd
local fn = vim.fn

local parsers = require('nvim-treesitter.parsers')

local M = {}

function M.create_augroups(definitions)
  for group_name, definition in pairs(definitions) do
    cmd('augroup ' .. group_name)
    cmd('autocmd!')
    for _, def in ipairs(definition) do
      local command = table.concat(vim.tbl_flatten{'autocmd', def}, ' ')
      cmd(command)
    end
    cmd('augroup END')
  end
end

-- This function is pretty much `get_node_at_cursor()` copied from 
-- `nvim-treesitter`, but instead will return the node that starts at the first 
-- non-whitespace column on the cursor's line.
--
-- For example, if the cursor is at "|":
--    |   <div>
--
-- then will return the <div> node, even though it isn't at the cursor position
function M.get_node_at_cursor_start_of_line(winnr)
  if not parsers.has_parser() then return end
  local cursor = api.nvim_win_get_cursor(winnr or 0)
  local root = parsers.get_parser():parse()[1]:root()

  local first_non_whitespace_col = fn.match(fn.getline('.'), '\\S')

  return root:named_descendant_for_range(
    cursor[1] - 1,
    first_non_whitespace_col,
    cursor[1] - 1,
    first_non_whitespace_col
  )
end

return M
