local api = vim.api

local utils = require('ts_context_commentstring.utils')
local configs = require('nvim-treesitter.configs')

local M = {}

-- The configuration object keys should be **treesitter** languages, NOT 
-- filetypes or file extensions.
--
-- You can get the treesitter language for the current file by running this 
-- command:
-- `:lua print(require'nvim-treesitter.parsers'.get_buf_lang(0))`
--
-- Or the injected language for a specific location:
-- `:lua print(require'nvim-treesitter.parsers'.get_parser():language_for_range({ line, col, line, col }):lang())`
M.config = {
  -- Languages that have a single comment style
  typescript = '// %s',
  css = '/* %s */',
  scss = '/* %s */',
  php = '// %s',
  html = '<!-- %s -->',
  svelte = '<!-- %s -->',

  -- Languages that can have multiple types of comments
  tsx = {
    __default = '// %s',
    jsx_element = '{/* %s */}',
    jsx_fragment = '{/* %s */}',
    jsx_attribute = '// %s',
    comment = '// %s',
  },
  javascript = {
    __default = '// %s',
    jsx_element = '{/* %s */}',
    jsx_fragment = '{/* %s */}',
    jsx_attribute = '// %s',
    comment = '// %s',
  },
}

-- Initialize the plugin in the current buffer
function M.setup_buffer()
  -- Save the original commentstring so that it can be restored later if there
  -- is no match
  api.nvim_buf_set_var(0, 'ts_original_commentstring', api.nvim_buf_get_option(0, 'commentstring'))

  local enable_autocmd = configs.get_module('context_commentstring').enable_autocmd
  enable_autocmd = enable_autocmd == nil and true or enable_autocmd

  -- If vim-commentary is installed, set up mappings for it
  if vim.g.loaded_commentary == 1 then
    enable_autocmd = false
    require('ts_context_commentstring.integrations.vim_commentary').set_up_maps()
  end

  if enable_autocmd then
    utils.create_augroups({
      context_commentstring_ft = {
        {'CursorHold', '<buffer>', [[lua require('ts_context_commentstring.internal').update_commentstring()]]},
      },
    })
  end
end

-- Calculate the commentstring based on the current location of the cursor.
--
-- **Note:** We should treat this function like a public API, try not to break 
-- it!
--
-- @returns the commentstring or nil if not found
function M.calculate_commentstring()
  local node, language_tree = utils.get_node_at_cursor_start_of_line(
    vim.tbl_keys(M.config)
  )

  if not node and not language_tree then
    return nil
  end

  local language = language_tree:lang()
  local language_config = M.config[language]

  return M.check_node(node, language_config)
end

-- Update the `commentstring` setting based on the current location of the 
-- cursor. If no `commentstring` can be calculated, will revert to the ofiginal 
-- `commentstring` for the current file.
--
-- **Note:** We should treat this function like a public API, try not to break 
-- it!
function M.update_commentstring()
  local found_commentstring = M.calculate_commentstring()

  if found_commentstring then
    api.nvim_buf_set_option(0, 'commentstring', found_commentstring)
  else
    -- No commentstring was found, default to the
    local original_commentstring = vim.b.ts_original_commentstring
    if original_commentstring then
      api.nvim_buf_set_option(0, 'commentstring', vim.b.ts_original_commentstring)
    end
  end
end

-- Check if the given node matches any of the given types. If not, recursively
-- check its parent node.
function M.check_node(node, language_config)
  -- There is no commentstring configuration for this language, use the 
  -- `ts_original_commentstring`
  if not language_config then return nil end

  -- There is no node, we have reached the top-most node, use the default 
  -- commentstring from language config
  if not node then
    return language_config.__default or language_config
  end

  local type = node:type()
  local match = language_config[type]

  if match then return match end

  -- Recursively check the parent node
  return M.check_node(node:parent(), language_config)
end

-- Attach the module to the current buffer
function M.attach()
  M.config = vim.tbl_deep_extend(
    'force', M.config,
    configs.get_module('context_commentstring').config or {}
  )

  return M.setup_buffer()
end

function M.detach() return end

_G.context_commentstring = {}

-- Trigger re-calculation of the `commentstring` and trigger the given <Plug> 
-- mapping right after that.
--
-- This is in the global scope because 
-- `v:lua.require('ts_context_commentstring')` does not work for some reason.
function _G.context_commentstring.update_commentstring_and_run(mapping)
  M.update_commentstring()
  return vim.api.nvim_replace_termcodes('<Plug>' .. mapping, true, true, true)
end

return M
