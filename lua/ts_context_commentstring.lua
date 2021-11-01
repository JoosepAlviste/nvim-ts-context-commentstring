local M = {}

function M.init()
  require('nvim-treesitter').define_modules {
    context_commentstring = {
      module_path = 'ts_context_commentstring.internal',
    },
  }
end

return M
