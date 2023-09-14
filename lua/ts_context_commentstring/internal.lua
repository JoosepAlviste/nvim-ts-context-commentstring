local api = vim.api

local utils = require 'ts_context_commentstring.utils'
local config = require 'ts_context_commentstring.config'

local M = {}

---Initialize the plugin in the current buffer
function M.setup_buffer()
  if not utils.is_treesitter_active() then
    return
  end

  -- Save the original commentstring so that it can be restored later if there
  -- is no match
  api.nvim_buf_set_var(0, 'ts_original_commentstring', api.nvim_buf_get_option(0, 'commentstring'))

  local enable_autocmd = config.is_autocmd_enabled()

  -- If vim-commentary is installed, set up mappings for it
  if vim.g.loaded_commentary == 1 then
    require('ts_context_commentstring.integrations.vim_commentary').set_up_maps(config.config.commentary_integration)
  end

  if enable_autocmd then
    local group = api.nvim_create_augroup('context_commentstring_ft', { clear = true })
    api.nvim_create_autocmd('CursorHold', {
      buffer = 0,
      group = group,
      desc = 'Change the commentstring on cursor hold using Treesitter',
      callback = function()
        require('ts_context_commentstring').update_commentstring()
      end,
    })
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
---@param args? ts_context_commentstring.Args
---
---@return string | nil commentstring If found, otherwise `nil`
function M.calculate_commentstring(args)
  args = args or {}
  local key = args.key or '__default'
  local location = args.location or nil

  local node, language_tree =
    utils.get_node_at_cursor_start_of_line(vim.tbl_keys(config.get_languages_config()), location)

  if not node and not language_tree then
    return nil
  end

  local custom_calculation = config.config.custom_calculation
  if custom_calculation then
    local commentstring = custom_calculation(node, language_tree)
    if commentstring then
      return commentstring
    end
  end

  local language = language_tree:lang()
  local language_config = config.get_languages_config()[language]

  return M.check_node(node, language_config, key)
end

---Update the `commentstring` setting based on the current location of the
---cursor. If no `commentstring` can be calculated, will revert to the ofiginal
---`commentstring` for the current file.
---
---**Note:** We should treat this function like a public API, try not to break
---it!
---
---@param args? ts_context_commentstring.Args
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
  config.update(require('nvim-treesitter.configs').get_module 'context_commentstring')

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
  return api.nvim_replace_termcodes('<Plug>' .. mapping, true, true, true)
end

return M
