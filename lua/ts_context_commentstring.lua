local M = {}

---Set up non-default configuration
---@param config? ts_context_commentstring.Config
function M.setup(config)
  require('ts_context_commentstring.config').update(config)
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
