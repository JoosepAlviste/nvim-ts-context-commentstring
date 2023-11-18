if vim.g.loaded_ts_context_commentstring and vim.g.loaded_ts_context_commentstring ~= 0 then
  return
end

vim.g.loaded_ts_context_commentstring = 1

local group = vim.api.nvim_create_augroup('ts_context_commentstring', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = group,
  desc = 'Set up nvim-ts-context-commentstring for each buffer that has Treesitter active',
  callback = function(args)
    require('ts_context_commentstring.internal').setup_buffer(args.buf)
  end,
})

if not vim.g.skip_ts_context_commentstring_module or vim.g.skip_ts_context_commentstring_module == 0 then
  local nvim_ts_ok, nvim_ts = pcall(require, 'nvim-treesitter')
  if nvim_ts_ok then
    if not nvim_ts.define_modules then
      -- Running nvim-treesitter >= 1.0, modules are no longer a thing
      return
    end

    nvim_ts.define_modules {
      context_commentstring = {
        module_path = 'ts_context_commentstring.internal',
      },
    }
  end
end
