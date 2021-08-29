# kartograaf


Kartograaf serves to simplify the keymapping structure and eliminate much of the duplication you find in your lua neovim configs. Kartograaf also is just a fun exercise in TDD
in lua and nvim, something I have never done before. 

```viml
vim.api.nvim_set_keymap('i', 'jk', '<Esc', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

```
becomes
```lua
require('kartograaf').map({
  i = {
    { 'jk', '<Esc>' },
  },
  n = {
      mod = 'C',
      { 'h', '<C-w>h' },
      { 'j', '<C-w>j' },
      { 'k', '<C-w>k' },
      { 'l', '<C-w>l', { silent = true} },
    }
  }
})
```

### Installation

Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'stonelasley/kartograaf.nvim'
```

Using [dein](https://github.com/Shougo/dein.vim)

```viml
call dein#add('stonelasley/kartograaf.nvim')
```
Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'stonelasley/kartograaf.nvim',
}
```
### Usage

Looking through the tests will also help

```lua
require('kartograaf').map({
  i = {
    options = { noremap = false },
    { 'jk', '<Esc>' }, --api.nvim_set_keymap('i', 'jk', '<Esc>', { noremap = false })
  },
  n = {
    {
      prefix = '<leader>',
      { 'ls', ':ls<CR>:b<space>', { silent = true }} -- api.nvim_set_keymap('n', '<leader>ls', ':ls<CR>:b<space>', { noremap = true, silent = true })
    },
    {
      mod = 'C',
      { 'h', '<C-w>h' }, -- api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true })
    },
    {
      mod = 'M',
      { 'j', ':resize-2' }, -- api.nvim_set_keymap('n', '<M-j>', ':resize-2', { noremap = true })
    }
  },
  c = {
    { 'w!!', 'w !sudo tee %'}
  }
})
```

#### Buffer maps
```lua
require('kartograaf').map({
  buffer = 1234,
  i = {
    options = { noremap = false },
    { 'jk', '<Esc>' }, --api.nvim_buf_set_keymap(1234, 'i', 'jk', '<Esc>', { noremap = false })
  },
  n = {
    buffer = 456,
    mod = 'C',
    { 'h', '<C-w>h' }, --api.nvim_buf_set_keymap(456, 'n', '<C-h>', '<C-w>h', { noremap = true})
  } 
})
```

#### Debugging
```lua
require('kartograaf').map({
  debug = true, -- prints out map statements
  i = {
    options = { noremap = false },
    { 'jk', '<Esc>' }, --api.nvim_buf_set_keymap(1234, 'i', 'jk', '<Esc>', { noremap = false })
  },
  n = {
    buffer = 456,
    mod = 'C',
    { 'h', '<C-w>h' }, --api.nvim_buf_set_keymap(456, 'n', '<C-h>', '<C-w>h', { noremap = true})
  } 
})
```

### Development dependencies

  'nvim-lua/plenary.nvim' (to run tests)
  
## Credits
This plugin was influenced by (lionc/nest.nvim)[https://github.com/lionc/nest.nvim]. I like the idea 
of nest's configuration but I was running into issues debugging setup and then ran into bigger 
issues modifying it to set buffer keymaps. And here we are.
