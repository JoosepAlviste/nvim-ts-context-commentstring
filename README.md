# `nvim-ts-context-commentstring`

A Neovim plugin for setting the `commentstring` option based on the cursor
location in the file. The location is checked via treesitter queries.

This is useful when there are embedded languages in certain types of files. For
example, Vue files can have many different sections, each of which can have a
different style for comments.

Note that this plugin *only* changes the `commentstring` setting. It does not 
add any mappings for commenting. It is recommended to use a commenting plugin 
like [`Comment.nvim`](https://github.com/numToStr/Comment.nvim) alongside this 
plugin.

![Demo gif](https://user-images.githubusercontent.com/9450943/185669080-a5f05064-c247-47f5-9b63-d34a9871186e.gif)



## Getting started

**Requirements:**

- [Neovim version 0.9.4](https://github.com/neovim/neovim/releases/tag/v0.9.4)
- Tree-sitter parsers (e.g. installed with [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter))

**Installation:**

Use your favorite plugin manager. For example, here's how it would look like
with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
require('lazy').setup {
  'JoosepAlviste/nvim-ts-context-commentstring',
}
```

**Setup:**

For most commenting plugins, this is all you need and the defaults should work 
out of the box. However, some commenting plugins require a bit more set up. See 
the [Configuration section](#configuration) for more details about the different 
plugins.

If you want to change the configuration, call the `setup` function of this 
plugin, e.g.:

```lua
require('ts_context_commentstring').setup {
  enable_autocmd = false,
}
```

> **Note**
>
> There is a minimal configuration file available at 
> [`utils/minimal_init.lua`](https://github.com/JoosepAlviste/nvim-ts-context-commentstring/blob/main/utils/minimal_init.lua) for reference.

> **Note**
>
> Don't forget to use `:h lua-heredoc` if you're using `init.vim`.


## Configuration

It is recommended to use a commenting plugin that has an integration available 
with this plugin. Then, the `commentstring` calculation can be triggered only 
when commenting. The available integrations are listed in the 
[wiki](https://github.com/JoosepAlviste/nvim-ts-context-commentstring/wiki/Integrations). 
The following plugins have an integration available:

- [Native Neovim commenting](https://github.com/JoosepAlviste/nvim-ts-context-commentstring/wiki/Integrations#native-commenting-in-neovim-010)
- [`b3nj5m1n/kommentary`](https://github.com/JoosepAlviste/nvim-ts-context-commentstring/wiki/Integrations#kommentary)
- [`terrortylor/nvim-comment`](https://github.com/JoosepAlviste/nvim-ts-context-commentstring/wiki/Integrations#nvim-comment)
- [`numToStr/Comment.nvim`](https://github.com/JoosepAlviste/nvim-ts-context-commentstring/wiki/Integrations#commentnvim)
- [`echasnovski/mini.nvim/mini-comment`](https://github.com/JoosepAlviste/nvim-ts-context-commentstring/wiki/Integrations#minicomment)
- [`tpope/vim-commentary`](https://github.com/JoosepAlviste/nvim-ts-context-commentstring/wiki/Integrations#vim-commentary)

However, if an integration is not set up, then the default behavior is to 
calculate the `commentstring` on the `CursorHold` autocmd, meaning that the 
`:h updatetime` should be set to a smaller value than the default of 4s:

```lua
vim.opt.updatetime = 100
```

> **Note**
>
> For more advanced configuration options, see `:h ts-context-commentstring`.


## More demos

**React:**

![React demo gif](https://user-images.githubusercontent.com/9450943/185669182-d523c328-251e-41b0-a76e-d867c401a040.gif)

**Svelte:**

![Svelte demo gif](https://user-images.githubusercontent.com/9450943/185669229-ad10848e-ba13-45e0-8447-a3a1f03eb85e.gif)

**HTML:**

![html](https://user-images.githubusercontent.com/9450943/185669275-cdfa7fa4-092e-439b-822e-330559a7d4d7.gif)

**Nesting:**

I injected HTML into JavaScript strings and created multiple levels of nesting 
with language tree. This sort of nesting of languages works without any extra 
configuration in the plugin.

![nested](https://user-images.githubusercontent.com/9450943/185669303-e6958706-f5b7-439c-98f7-2393e6325107.gif)
