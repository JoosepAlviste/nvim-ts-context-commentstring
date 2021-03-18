local M = {}

function M.init()
  require('nvim-treesitter').define_modules {
    context_commentstring = {
      module_path = "ts_context_commentstring.internal",
      is_supported = function(lang)
        return require('ts_context_commentstring.internal').config[lang] ~= nil
      end
    }
  }
end

return M
