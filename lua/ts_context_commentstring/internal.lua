local api = vim.api

local utils = require('ts_context_commentstring.utils')
local configs = require('nvim-treesitter.configs')
local parsers = require('nvim-treesitter.parsers')

local M = {}

-- The configuration object keys should be **treesitter** languages, NOT 
-- filetypes or file extensions.
-- You can get the treesitter language by running this command:
-- `:lua print(require'nvim-treesitter.parsers'.get_buf_lang(0))`
M.config = {
  tsx = {
    jsx_element = '{/* %s */}',
    jsx_fragment = '{/* %s */}',
    jsx_attribute = '// %s',
    comment = '// %s',
  },
  javascript = {
    jsx_element = '{/* %s */}',
    jsx_fragment = '{/* %s */}',
    jsx_attribute = '// %s',
    comment = '// %s',
  },
  vue = {
    script_element = '// %s',
    template_element = '<!-- %s -->',
    style_element = '/* %s */',
  },
  svelte = {
    script_element = '// %s',
    style_element = '/* %s */',
    element = '<!-- %s -->',
    comment = '<!-- %s -->',
  },
  html = {
    style_element = '/* %s */',
    script_element = '// %s',
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

-- Update the commentstring based on the current location of the cursor
function M.update_commentstring()
  local node = utils.get_node_at_cursor_start_of_line()
  local looking_for = M.config[parsers.get_buf_lang(0)]

  if looking_for then
    local found_type = M.check_node(node, looking_for)

    if found_type then
      api.nvim_buf_set_option(0, 'commentstring', looking_for[found_type])
    else
      api.nvim_buf_set_option(0, 'commentstring', api.nvim_buf_get_var(0, 'ts_original_commentstring'))
    end
  end
end

-- Check if the given node matches any of the given types. If not, recursively
-- check its parent node.
function M.check_node(node, looking_for)
  if not node then return nil end

  local type = node:type()
  local match = looking_for[type]

  if match then return type end

  -- Recursively check the parent node
  return M.check_node(node:parent(), looking_for)
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
