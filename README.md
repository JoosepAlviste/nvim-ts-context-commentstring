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

Call the `setup()` function in your configuration file:

```vim
lua <<EOF
require('ts_context_commentstring').setup()
EOF
```


## More demos

**React:**

![React demo gif](demo/react.gif)
