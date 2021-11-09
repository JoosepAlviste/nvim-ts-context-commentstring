local map = vim.api.nvim_buf_set_keymap

local M = {}

---Set up vim-commentary mappings to first update the commentstring, and then
---run vim-commentary
function M.set_up_maps()
  map(0, 'n', 'gc', [[v:lua.context_commentstring.update_commentstring_and_run('Commentary')]], { expr = true })
  map(0, 'x', 'gc', [[v:lua.context_commentstring.update_commentstring_and_run('Commentary')]], { expr = true })
  map(0, 'o', 'gc', [[v:lua.context_commentstring.update_commentstring_and_run('Commentary')]], { expr = true })
  map(0, 'n', 'gcc', [[v:lua.context_commentstring.update_commentstring_and_run('CommentaryLine')]], { expr = true })
  map(0, 'n', 'cgc', [[v:lua.context_commentstring.update_commentstring_and_run('ChangeCommentary')]], { expr = true })
end

return M
