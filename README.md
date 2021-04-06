# `nvim-ts-context-commentstring`

A Neovim plugin for setting the `commentstring` option based on the cursor
location in the file. The location is checked via treesitter queries.

This is useful when there are embedded languages in certain types of files. For
example, Vue files can have many different sections, each of which can have a
different style for comments.

Note that this plugin *only* changes the `commentstring` setting. It does not 
add any mappings for commenting. It is recommended to use a commenting plugin 
like [`vim-commentary`](https://github.com/tpope/vim-commentary/) alongside this 
plugin.

![Demo gif](demo/demo.gif)


## Getting started

**Requirements:**

- [Neovim nightly (version 0.5
  prerelease)](https://github.com/neovim/neovim/releases/tag/nightly)
- [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter/)

**Installation:**

Use your favorite plugin manager. For example, here's how it would look like
with Packer:

```lua
use 'JoosepAlviste/nvim-ts-context-commentstring'
```

**Setup:**

Enable the module from `nvim-treesitter` setup

```lua
require'nvim-treesitter.configs'.setup {
  context_commentstring = {
    enable = true
  }
}
```

Don't forget to use [lua
heredoc](https://github.com/nanotee/nvim-lua-guide#using-lua-from-vimscript) if
you're using `init.vim`

**Recommended: Using a commenting plugin**

It is recommended to use a commenting plugin like 
[`vim-commentary`](https://github.com/tpope/vim-commentary/) together with this 
plugin. `vim-commentary` provides the mappings for commenting which use the 
`commentstring` setting. This plugin adds to that by correctly setting the 
`commentstring` setting so that `vim-commentary` can do its thing even in more 
complex filetypes.

There is an additional integration with `vim-commentary` specifically, which 
optimizes the `commentstring` updating logic so that it is not run 
unnecessarily. If `vim-commentary` is detected, then this plugin automatically 
sets up `vim-commentary` mappings to first update the `commentstring`, and then 
trigger `vim-commentary`.

Let me know if you'd like a similar integration for another commenting plugin.


## Configuration

### Adding support for more languages

Currently, the following languages are supported (see 
[`lua/ts_context_commentstring/internal.lua`](./lua/ts_context_commentstring/internal.lua)):

- `html`
- `javascript` (React in JS)
- `tsx` (React in TypeScript)
- `vue`
- `svelte`

If you'd like to add more or override any, pass a `config` table.

```lua
require'nvim-treesitter.configs'.setup {
  context_commentstring = {
    enable = true,
    config = {
      vue = {
        style_element = '// %s',
      },
    }
  }
}
```

The `style_element` refers to the type of the treesitter node. In this example,
if your cursor is inside a `style_element`, the `// %s` `commentstring` will be
set.

Note that the language (`vue` in the example) refers to the **treesitter** 
language, not filetype or file extension.

### Behavior

The default behavior is to trigger `commentstring` updating on `CursorHold`. If
your `updatetime` setting is set to a high value, then the updating might not
be triggered. Let me know if you'd like to have this be customized by creating
an issue. Another candidate might be the `CursorMoved` autocommand.

The default `CursorHold` autocommand can be disabled by passing `enable_autocmd 
= false` when setting up the plugin:

```lua
require'nvim-treesitter.configs'.setup {
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  }
}
```

Then, you can call the `update_commentstring` function manually:

```lua
nnoremap <leader>c <cmd>lua require('ts_context_commentstring.internal').update_commentstring()<cr>
```

**Note:** It is not necessary to use this option if you are using 
`vim-commentary`, the integration is set up automatically.


## More demos

**React:**

![React demo gif](demo/react.gif)

**Svelte:**

![Svelte demo gif](demo/svelte.gif)

**HTML:**

![HTML demo gif](demo/html.gif)
