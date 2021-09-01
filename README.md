# kartograaf


Kartograaf serves to simplify the keymapping structure and eliminate much of the duplication you find in your lua neovim configs. Kartograaf also is just a fun exercise in TDD
in lua and nvim, something I have never done before. 

```viml
vim.api.nvim_set_keymap('i', 'jk', '<Esc', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>tw', '<cmd>Trouble lsp_workspace_diagnostics<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gd,  '<Plug>(omnisharp_go_to_definition)', { noremap = false })
vim.api.nvim_set_keymap('n', 'gi  '<Plug>(omnisharp_find_implementations)', { noremap = false })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-r><C-r>', '<C-w>l', { noremap = true, silent = true })
```
####becomes
```lua
require('kartograaf').map({
  i = {
    { 'jk', '<Esc>' },
  },
  n = {
    {
      prefix = '<leader>',
      { 'tw', '<cmd>Trouble lsp_workspace_diagnostics<CR>'}, { silent = true},
    },
    {
      options = { noremap = false },
      prefix = 'g',
      { 'd', '<Plug>(omnisharp_go_to_definition)'},
      { 'i', '<Plug>(omnisharp_find_implementations)'},
    },
    {
      mod = 'C',
      { 'k', '<C-w>k' },
      { 'r,r', '<C-w>l' }
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
    options = { noremap = false }, -- set to all maps in this mode, merged with higher options
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
      { 'l', '<C-w>l' }, -- api.nvim_set_keymap('n', '<C-l>', '<C-w>l, { noremap = true })
    },
    {
      mod = 'M',
      { 'j', ':resize-2' }, -- api.nvim_set_keymap('n', '<M-j>', ':resize-2', { noremap = true })
    }
  },
  c = {
    options = { silent = true }
    { 'w!!', 'w !sudo tee %'} -- api.nvim_set_keymap('c', 'w!!', 'w !sudo tee %', { silent = true })
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
    { 'jk', '<Esc>' }, --print('api.nvim_set_keymap('i', 'jk', '<Esc>', { noremap = false })')
  },
  n = {
    buffer = 456,
    mod = 'C',
    { 'h', '<C-w>h' }, --print('api.nvim_buf_set_keymap(456, 'n', '<C-h>', '<C-w>h', { noremap = true})')
  } 
})
```

### Development dependencies

  'nvim-lua/plenary.nvim' (to run tests)
  
## Credits
This plugin was influenced by [lionc/nest.nvim](https://github.com/lionc/nest.nvim). I like the idea 
of nest's configuration but I was running into issues debugging setup and then ran into bigger 
issues modifying it to set buffer keymaps. And here we are.
