local api = vim.api
local cmd = vim.cmd

local utils = require 'ts_context_commentstring.utils'
local configs = require 'nvim-treesitter.configs'

local M = {}

---A commentstring configuration that includes both single and multi-line
---comments. The fields can be anything and they will be retrievable with the
---`key` option to `update_commentstring`.
---@class ts_context_commentstring.CommentConfigMultiple
---@field __default string Single-line commentstring
---@field __multiline string Multi-line commentstring

---Commentstring configuration can either be a string (a single commenting
---style) or a table specifying multiple styles.
---@alias ts_context_commentstring.CommentConfig string | ts_context_commentstring.CommentConfigMultiple

---The comment configuration for a language.
---@alias ts_context_commentstring.LanguageConfig ts_context_commentstring.CommentConfig | table<string, ts_context_commentstring.CommentConfig>

---Configuration of the whole plugin, mapping languages to commentstring
---configs.
---@alias ts_context_commentstring.Config table<string, ts_context_commentstring.LanguageConfig>

---The configuration object keys should be **treesitter** languages, NOT
---filetypes or file extensions.
---
---You can get the treesitter language for the current file by running this
---command:
---`:lua print(require'nvim-treesitter.parsers'.get_buf_lang(0))`
---
---Or the injected language for a specific location:
---`:lua print(require'nvim-treesitter.parsers'.get_parser():language_for_range({ line, col, line, col }):lang())`
---
---@type ts_context_commentstring.Config
M.config = {
  -- Languages that have a single comment style
  typescript = { __default = '// %s', __multiline = '/* %s */' },
  css = '/* %s */',
  scss = '/* %s */',
  php = { __default = '// %s', __multiline = '/* %s */' },
  html = '<!-- %s -->',
  svelte = '<!-- %s -->',
  vue = '<!-- %s -->',
  handlebars = '{{! %s }}',
  glimmer = '{{! %s }}',
  graphql = '# %s',
  lua = { __default = '-- %s', __multiline = '--[[ %s ]]' },
  vim = '" %s',

  -- Languages that can have multiple types of comments
  tsx = {
    __default = '// %s',
    __multiline = '/* %s */',
    jsx_element = '{/* %s */}',
    jsx_fragment = '{/* %s */}',
    jsx_attribute = { __default = '// %s', __multiline = '/* %s */' },
    comment = { __default = '// %s', __multiline = '/* %s */' },
    call_expression = { __default = '// %s', __multiline = '/* %s */' },
    statement_block = { __default = '// %s', __multiline = '/* %s */' },
  },
  javascript = {
    __default = '// %s',
    __multiline = '/* %s */',
    jsx_element = '{/* %s */}',
    jsx_fragment = '{/* %s */}',
    jsx_attribute = { __default = '// %s', __multiline = '/* %s */' },
    comment = { __default = '// %s', __multiline = '/* %s */' },
    call_expression = { __default = '// %s', __multiline = '/* %s */' },
    statement_block = { __default = '// %s', __multiline = '/* %s */' },
  },
}

---Initialize the plugin in the current buffer
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
    cmd 'augroup context_commentstring_ft '
    cmd 'autocmd!'
    cmd [[autocmd CursorHold <buffer> lua require('ts_context_commentstring.internal').update_commentstring()]]
    cmd 'augroup END'
  end
end

---@class ts_context_commentstring.Args
---@field key string Key to prefer to be returned from ts_context_commentstring.CommentConfigMultiple
---@field location ts_context_commentstring.Location

---Calculate the commentstring based on the current location of the cursor.
---
---**Note:** We should treat this function like a public API, try not to break
---it!
---
---@param args ts_context_commentstring.Args
---
---@return string | nil commentstring If found, otherwise `nil`
function M.calculate_commentstring(args)
  args = args or {}
  local key = args.key or '__default'
  local location = args.location or nil

  local node, language_tree = utils.get_node_at_cursor_start_of_line(vim.tbl_keys(M.config), location)

  if not node and not language_tree then
    return nil
  end

  local custom_calculation = configs.get_module('context_commentstring').custom_calculation
  if custom_calculation then
    local commentstring = custom_calculation(node, language_tree)
    if commentstring then
      return commentstring
    end
  end

  local language = language_tree:lang()
  local language_config = M.config[language]

  return M.check_node(node, language_config, key)
end

---Update the `commentstring` setting based on the current location of the
---cursor. If no `commentstring` can be calculated, will revert to the ofiginal
---`commentstring` for the current file.
---
---**Note:** We should treat this function like a public API, try not to break
---it!
---
---@param args ts_context_commentstring.Args
function M.update_commentstring(args)
  local found_commentstring = M.calculate_commentstring(args)

  if found_commentstring then
    api.nvim_buf_set_option(0, 'commentstring', found_commentstring)
  else
    -- No commentstring was found, default to the default for this buffer
    local original_commentstring = vim.b.ts_original_commentstring
    if original_commentstring then
      api.nvim_buf_set_option(0, 'commentstring', vim.b.ts_original_commentstring)
    end
  end
end

---Check if the given node matches any of the given types. If not, recursively
---check its parent node.
---
---@param node table
---@param language_config ts_context_commentstring.LanguageConfig
---@param commentstring_key string
---
---@return string | nil
function M.check_node(node, language_config, commentstring_key)
  commentstring_key = commentstring_key or '__default'

  -- There is no commentstring configuration for this language, use the
  -- `ts_original_commentstring`
  if not language_config then
    return nil
  end

  -- There is no node, we have reached the top-most node, use the default
  -- commentstring from language config
  if not node then
    return language_config[commentstring_key] or language_config.__default or language_config
  end

  local node_type = node:type()
  local match = language_config[node_type]

  if match then
    return match[commentstring_key] or match.__default or match
  end

  -- Recursively check the parent node
  return M.check_node(node:parent(), language_config, commentstring_key)
end

---Attach the module to the current buffer
function M.attach()
  M.config = vim.tbl_deep_extend('force', M.config, configs.get_module('context_commentstring').config or {})

  return M.setup_buffer()
end

function M.detach() end

_G.context_commentstring = {}

---Trigger re-calculation of the `commentstring` and trigger the given <Plug>
---mapping right after that.
---
---This is in the global scope because
---`v:lua.require('ts_context_commentstring')` does not work for some reason.
---
---@param mapping string The Plug mapping to execute
---
---@return string
function _G.context_commentstring.update_commentstring_and_run(mapping)
  M.update_commentstring()
  return vim.api.nvim_replace_termcodes('<Plug>' .. mapping, true, true, true)
end

return M
