local gmap = vim.api.nvim_set_keymap
local bmap = vim.api.nvim_buf_set_keymap

for _, mode in ipairs { 'n', 'x', 'o' } do
  gmap(
    mode,
    '<Plug>ContextCommentary',
    [[v:lua.context_commentstring.update_commentstring_and_run('Commentary')]],
    { expr = true }
  )
end
gmap(
  'n',
  '<Plug>ContextCommentaryLine',
  [[v:lua.context_commentstring.update_commentstring_and_run('CommentaryLine')]],
  { expr = true }
)
gmap(
  'n',
  '<Plug>ContextChangeCommentary',
  [[v:lua.context_commentstring.update_commentstring_and_run('ChangeCommentary')]],
  { expr = true }
)

local M = {}

---Set up vim-commentary mappings to first update the commentstring, and then
---run vim-commentary
---@param maps ts_context_commentstring.CommentaryConfig
function M.set_up_maps(maps)
  if maps.Commentary then
    for _, mode in ipairs { 'n', 'x', 'o' } do
      bmap(0, mode, maps.Commentary, '<Plug>ContextCommentary', {})
    end
  end
  if maps.CommentaryLine then
    bmap(0, 'n', maps.CommentaryLine, '<Plug>ContextCommentaryLine', {})
  end
  if maps.ChangeCommentary then
    bmap(0, 'n', maps.ChangeCommentary, '<Plug>ContextChangeCommentary', {})
  end
  if maps.CommentaryUndo then
    bmap(0, 'n', maps.CommentaryUndo, '<Plug>ContextCommentary<Plug>Commentary', {})
  end
end

return M
