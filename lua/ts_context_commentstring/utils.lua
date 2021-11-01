local api = vim.api
local cmd = vim.cmd
local fn = vim.fn

local parsers = require 'nvim-treesitter.parsers'

local M = {}

function M.create_augroups(definitions)
  for group_name, definition in pairs(definitions) do
    cmd('augroup ' .. group_name)
    cmd 'autocmd!'
    for _, def in ipairs(definition) do
      local command = table.concat(vim.tbl_flatten { 'autocmd', def }, ' ')
      cmd(command)
    end
    cmd 'augroup END'
  end
end

-- Get the language tree from the given parser that is in the given range. Only
-- accept the given languages. Ignores all language trees with a language not
-- included in `only_languages` parameter.
--
-- This function is pretty much copied from Neovim core
-- (`LanguageTree:language_for_range`), but includes filtering of the injected
-- languages.
local function language_for_range(parser, range, only_languages)
  for _, child in pairs(parser._children) do
    if child:contains(range) then
      local result = language_for_range(child, range, only_languages)

      if not vim.tbl_contains(only_languages, result:lang()) then
        return parser
      end

      return result
    end
  end

  return parser
end

-- Check if the given language tree contains the given range.
-- This function is copied from Neovim core.
local function tree_contains(tree, range)
  local start_row, start_col, end_row, end_col = tree:root():range()
  local start_fits = start_row < range[1] or (start_row == range[1] and start_col <= range[2])
  local end_fits = end_row > range[3] or (end_row == range[3] and end_col >= range[4])

  if start_fits and end_fits then
    return true
  end

  return false
end

-- Get the node that is on the same line as the cursor, but on the first
-- NON-WHITESPACE character. This also handles injected languages via language
-- tree.
--
-- For example, if the cursor is at "|":
--    |   <div>
--
-- then will return the <div> node, even though it isn't at the cursor position
--
-- Returns the node at the cursor's line and the language tree for that
-- injection.
function M.get_node_at_cursor_start_of_line(only_languages, winnr)
  if not parsers.has_parser() then
    return
  end

  -- Get the position for the queried node
  local cursor = api.nvim_win_get_cursor(winnr or 0)
  local first_non_whitespace_col = fn.match(fn.getline '.', '\\S')
  local range = {
    cursor[1] - 1,
    first_non_whitespace_col,
    cursor[1] - 1,
    first_non_whitespace_col,
  }

  -- Get the language tree with nodes inside the given range
  local root = parsers.get_parser()
  local language_tree = language_for_range(root, range, only_languages)

  -- Get the sub-tree of the language tree that contains the given range.
  -- If there are multiple trees in the buffer for the same injected language,
  -- then we need to make sure that we are operating on the correct tree.
  local tree = vim.tbl_filter(function(tree)
    return tree_contains(tree, range)
  end, language_tree:trees())[1]

  -- avoid crash on empty files
  if not tree then
    return nil, language_tree
  end

  -- Get the actual node on the location
  local injected_root = tree:root()
  local node = injected_root:named_descendant_for_range(unpack(range))

  return node, language_tree
end

return M
