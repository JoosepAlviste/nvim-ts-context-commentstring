local api = vim.api

local utils = require('ts_context_commentstring.utils')

local M = {}

M.config = {
  typescriptreact = {
    jsx_element = '{/* %s */}',
    jsx_attribute = '// %s',
    comment = '// %s',
  },
  vue = {
    script_element = '// %s',
    template_element = '<!-- %s -->',
    style_element = '/* %s */',
  },
}

-- Bootstrap the plugin
--
-- Add an autocmd for each filetype in the config which will initialize the 
-- plugin in that filetype.
function M.setup()
  local file_types = vim.tbl_keys(M.config)

  local autocmds = vim.tbl_map(function (file_type)
    return {'FileType', file_type, [[lua require('ts_context_commentstring').setup_filetype()]]}
  end, file_types)

  utils.create_augroups({context_commentstring = autocmds})
end

-- Initialize the plugin in the current buffer
function M.setup_filetype()
  -- Save the original commentstring so that it can be restored later if there 
  -- is no match
  api.nvim_buf_set_var(0, 'ts_original_commentstring', api.nvim_buf_get_option(0, 'commentstring'))

  utils.create_augroups({
    context_commentstring_ft = {
      {'CursorHold', '<buffer>', [[lua require('ts_context_commentstring').update_commentstring()]]},
    },
  })
end

-- Update the commentstring based on the current location of the cursor
function M.update_commentstring()
  local node = utils.get_node_at_cursor_start_of_line()
  local looking_for = M.config[vim.bo.ft]

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

return M
