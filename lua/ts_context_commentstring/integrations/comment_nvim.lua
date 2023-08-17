local M = {}

---Use this function to get a pre_hook function that can be used when
---configuring Comment.nvim.
---https://github.com/numToStr/Comment.nvim/
---
---Example usage:
---```lua
---require('Comment').setup {
---  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
---}
---```
---
---Feel free to copy this function into your own configuration if you need to
---make any changes (or contribute the improvements back into this plugin).
---
---This is a higher order function in case we want to add any extra
---configuration for the hook in the future.
---
---@return fun(ctx: CommentCtx): string|nil
function M.create_pre_hook()
  ---@param ctx CommentCtx
  ---@return string|nil
  return function(ctx)
    local U = require 'Comment.utils'

    -- Determine whether to use linewise or blockwise commentstring
    local type = ctx.ctype == U.ctype.linewise and '__default' or '__multiline'

    -- Determine the location where to calculate commentstring from
    local location = nil
    if ctx.ctype == U.ctype.blockwise then
      location = {
        ctx.range.srow - 1,
        ctx.range.scol,
      }
    elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
      location = require('ts_context_commentstring.utils').get_visual_start_location()
    end

    return require('ts_context_commentstring').calculate_commentstring {
      key = type,
      location = location,
    }
  end
end

return M
