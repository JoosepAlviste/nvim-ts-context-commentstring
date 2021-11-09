local api = vim.api
local fn = vim.fn

local parsers = require 'nvim-treesitter.parsers'

---@alias ts_context_commentstring.Location number[] 2-tuple of (line, column)

local M = {}

---Get the language tree from the given parser that is in the given range. Only
---accept the given languages. Ignores all language trees with a language not
---included in `only_languages` parameter.
---
---This function is pretty much copied from Neovim core
---(`LanguageTree:language_for_range`), but includes filtering of the injected
---languages.
---
---@param parser table
---@param range number[]
---@param only_languages string[] Languages to keep, skip others
---
---@return table
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

---Check if the given language tree contains the given range.
---This function is copied from Neovim core.
---
---@param tree table
---@param range array
local function tree_contains(tree, range)
  local start_row, start_col, end_row, end_col = tree:root():range()
  local start_fits = start_row < range[1] or (start_row == range[1] and start_col <= range[2])
  local end_fits = end_row > range[3] or (end_row == range[3] and end_col >= range[4])

  if start_fits and end_fits then
    return true
  end

  return false
end

---Get the location of the cursor to be used to get the treesitter node
---function.
---
---@return ts_context_commentstring.Location
function M.get_cursor_location()
  local cursor = vim.api.nvim_win_get_cursor(0)
  return { cursor[1] - 1, cursor[2] }
end

---Get the location of the cursor line first non-blank character.
---
---@return ts_context_commentstring.Location
function M.get_cursor_line_non_whitespace_col_location()
  local cursor = api.nvim_win_get_cursor(0)
  local first_non_whitespace_col = fn.match(fn.getline '.', '\\S')

  return {
    cursor[1] - 1,
    first_non_whitespace_col,
  }
end

---Get the location of the visual section start.
---
---@return ts_context_commentstring.Location
function M.get_visual_start_location()
  local first_non_whitespace_col = fn.match(fn.getline '.', '\\S')

  return {
    vim.fn.getpos("'<")[2] - 1,
    first_non_whitespace_col,
  }
end

---Get the node that is on the given location (default first non-whitespace
---character of the cursor line). This also handles injected languages via
---language tree.
---
---For example, if the cursor is at "|":
---   |   <div>
---
---then will return the <div> node, even though it isn't at the cursor position
---
---Returns the node at the cursor's line and the language tree for that
---injection.
---
---@param only_languages string[] List of languages to filter for, all
---  other languages will be ignored.
---@param location? ts_context_commentstring.Location location Line, column
---  where to start traversing the tree. Defaults to cursor start of line.
---  This usually makes the most sense when commenting the whole line.
---
---@return table node, table language_tree Node and language tree for the
---  location
function M.get_node_at_cursor_start_of_line(only_languages, location)
  if not parsers.has_parser() then
    return
  end

  location = location or M.get_cursor_line_non_whitespace_col_location()
  local range = {
    location[1],
    location[2],
    location[1],
    location[2],
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
