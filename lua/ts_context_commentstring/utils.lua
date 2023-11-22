local api = vim.api
local fn = vim.fn

---Coordinates for a location. Both the line and the column are 0-indexed (e.g.,
---line nr 10 is line 9, the first column is 0).
---@alias ts_context_commentstring.Location number[] 2-tuple of (line, column)

local M = {}

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

---Get the location of the visual selection start.
---
---@return ts_context_commentstring.Location
function M.get_visual_start_location()
  local first_non_whitespace_col = fn.match(fn.getline '.', '\\S')

  return {
    vim.fn.getpos("'<")[2] - 1,
    first_non_whitespace_col,
  }
end

---Get the location of the visual selection end.
---
---@return ts_context_commentstring.Location
function M.get_visual_end_location()
  return {
    vim.fn.getpos("'>")[2] - 1,
    vim.fn.getpos("'>")[3] - 1,
  }
end

---@return boolean
---@param bufnr? number
function M.is_treesitter_active(bufnr)
  bufnr = bufnr or 0

  -- get_parser will throw an error if Treesitter is not set up for the buffer
  local ok, _ = pcall(vim.treesitter.get_parser, bufnr)

  return ok
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
---@return table|nil node, table|nil language_tree Node and language tree for the
---  location
function M.get_node_at_cursor_start_of_line()
  if not M.is_treesitter_active() then
    return
  end

  local location = M.get_cursor_line_non_whitespace_col_location()
  local range = {
    location[1],
    location[2],
    location[1],
    location[2],
  }

  -- default to top level language tree
  local language_tree = vim.treesitter.get_parser()
  -- Get the smallest supported language's tree with nodes inside the given range
  language_tree:for_each_tree(function(_, ltree)
    -- always exclude the comment language as it's returning invalid
    -- commentstring
    if ltree:contains(range) and ltree:lang() ~= 'comment' then
      language_tree = ltree
    end
  end)

  local node = language_tree:named_node_for_range(range)
  return node, language_tree
end

return M
