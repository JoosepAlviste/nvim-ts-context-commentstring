local M = {}

local status_ok, nvim_ts = pcall(require, 'nvim-treesitter')
if not status_ok then
  return
end

function M.init()
  if not nvim_ts.define_modules then
    -- Running nvim-treesitter >= 1.0, modules are no longer a thing
    return
  end

  nvim_ts.define_modules {
    context_commentstring = {
      module_path = 'ts_context_commentstring.internal',
    },
  }
end

---Set up the plugin manually, not as a nvim-treesitter module. This needs to be
---used if using nvim-treesitter 1.0 or above.
---@param config ts_context_commentstring.Config
function M.setup(config)
  require('ts_context_commentstring.config').update(config)

  local group = vim.api.nvim_create_augroup('context_commentstring', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    desc = 'Set up nvim-ts-context-commentstring for each buffer that has Treesitter active',
    callback = function()
      require('ts_context_commentstring.internal').setup_buffer()
    end,
  })
end

---Calculate the commentstring based on the current location of the cursor.
---
---@param args? ts_context_commentstring.Args
---
---@return string | nil commentstring If found, otherwise `nil`
function M.calculate_commentstring(args)
  return require('ts_context_commentstring.internal').calculate_commentstring(args)
end

---Update the `commentstring` setting based on the current location of the
---cursor. If no `commentstring` can be calculated, will revert to the ofiginal
---`commentstring` for the current file.
---
---@param args? ts_context_commentstring.Args
function M.update_commentstring(args)
  return require('ts_context_commentstring.internal').update_commentstring(args)
end

return M
