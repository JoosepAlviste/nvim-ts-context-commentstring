-- Install lazy.nvim automatically
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Or some other small value (Vim default is 4000)
vim.opt.updatetime = 100

require('lazy').setup {
  'JoosepAlviste/nvim-ts-context-commentstring',
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'vim', 'lua' },
        highlight = {
          enable = true,
        },
      }
    end,
  },
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup {
        pre_hook = function()
          return vim.bo.commentstring
        end,
      }
    end,
  },
}

-- Try commenting the following vimscript in and out with `gcc`, it should be
-- commented with a double quote character
vim.cmd [[
echo 'Hello World!'
]]
