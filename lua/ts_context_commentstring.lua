local M = {}

local status_ok, nvim_ts = pcall(require, 'nvim-treesitter')
if not status_ok then
  return
end

function M.init()
  nvim_ts.define_modules {
    context_commentstring = {
      module_path = 'ts_context_commentstring.internal',
    },
  }
end

return M
