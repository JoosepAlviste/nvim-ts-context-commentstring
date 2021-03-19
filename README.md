# `nvim-ts-context-commentstring`

A Neovim plugin for setting the `commentstring` option based on the cursor
location in the file. The location is checked via treesitter queries.

This is useful when there are embedded languages in certain types of files. For
example, Vue files can have many different sections, each of which can have a
different style for comments.

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

## Configuration

### Adding support for more languages

The plugin includes configurations for a few different languages (see
[`lua/ts_context_commentstring/internal.lua`](./lua/ts_context_commentstring/internal.lua)). 
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
if your cursor is inside a `style_element`, the `// %s` commentstring will be
set.

Note that the language (`vue` in the example) refers to the **treesitter** 
language, not filetype or file extension.

### Behavior

The default behavior is to trigger `commentstring` updating on `CursorHold`. If
your `updatetime` setting is set to a high value, then the updating might not
be triggered. Let me know if you'd like to have this be customized by creating
an issue. Another candidate might be the `CursorMoved` autocommand.

You could also not call the `.setup()` function, but instead manually call
`update_commentstring()`:

```lua
nnoremap <leader>c <cmd>lua require('ts_context_commentstring.internal').update_commentstring()<cr>
```


## More demos

**React:**

![React demo gif](demo/react.gif)
