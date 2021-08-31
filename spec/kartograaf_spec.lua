local mock = require('luassert.mock')

describe("Kartograaf", function()

  local cut = require('../lua/kartograaf')

  describe("map", function()
    it("Should call nvim_set_keymap", function()
      local maps = {}
      maps['i'] = { { 'l', 'r' } }
      maps['n'] = maps['i']


      local api = mock(vim.api, true)

      cut.map(maps)

      assert.stub(api.nvim_set_keymap).was_called_with('i', 'l', 'r', { noremap = true })
      assert.stub(api.nvim_set_keymap).was_called_with('n', 'l', 'r', { noremap = true })
      mock.revert(api)
    end)

    it("Should map with modifiers", function()
      local maps = {}
      maps['n'] = {
        {
          mod = 'C',
          { 'l', 'r' },
          { 'a', 'x' }
        }
      }


      local api = mock(vim.api, true)

      cut.map(maps)

      assert.stub(api.nvim_set_keymap).was_called_with('n', '<C-l>', 'r', { noremap = true })
      assert.stub(api.nvim_set_keymap).was_called_with('n', '<C-a>', 'x', { noremap = true })
      mock.revert(api)
    end)

    it("Should coalesce options", function()
      local mappings = {}
      mappings['i'] = {
        {
          mod = 'M',
          options = { a = '1' },
          { 'l', 'r', { b = 2 } }
        },
        {
          mod = 'C',
          options = { x = 'y' },
          { 'l', 'r', { w = 5 } }
        }
      }


      local api = mock(vim.api, true)

      cut.map(mappings)

      assert.stub(api.nvim_set_keymap).was_called_with('i', '<M-l>', 'r', { a = '1', b = 2, noremap = true })
      assert.stub(api.nvim_set_keymap).was_called_with('i', '<C-l>', 'r', { x = 'y', w = 5, noremap = true })
      mock.revert(api)
    end)

    it("Should allow explicit modifiers", function()
      local mappings = {}
      mappings['i'] = {
        {
          { '<C-l><C-l>', 'r', }
        }
      }


      local api = mock(vim.api, true)

      cut.map(mappings)

      assert.stub(api.nvim_set_keymap).was_called_with('i', '<C-l><C-l>', 'r', { noremap = true })
      mock.revert(api)
    end)

    it("Should coalesce mappings", function()
      local mappings = {}
      mappings['i'] = {
        {
          prefix = '<leader>',
          { '<leader>t', 'r', }
        }
      }


      local api = mock(vim.api, true)

      cut.map(mappings)

      assert.stub(api.nvim_set_keymap).was_called_with('i', '<leader><leader>t', 'r', { noremap = true })
      mock.revert(api)
    end)

    it("Should coalesce with modifiers mappings", function()
      local mappings = {}
      mappings['i'] = {
        {
          prefix = '<leader>',
          mod = 'C',
          { 't', 'r', }
        }
      }


      local api = mock(vim.api, true)

      cut.map(mappings)

      assert.stub(api.nvim_set_keymap).was_called_with('i', '<leader><C-t>', 'r', { noremap = true })
      mock.revert(api)
    end)

    it("Should allow plain prefix", function()
      local mappings = {}
      mappings['i'] = {
        {
          prefix = 'g',
          { 'd', 'r', }
        }
      }


      local api = mock(vim.api, true)

      cut.map(mappings)

      assert.stub(api.nvim_set_keymap).was_called_with('i', 'gd', 'r', { noremap = true })
      mock.revert(api)
    end)

    it("Should allow setting buffer", function()
      local mappings = {
        buffer = 456,
        i = {
          {
            prefix = '<leader>',
            { '<leader>l', 'lrx'},
          },
        },
        n = {
          options = { silent = true},
          {
            prefix = '<leader>',
            { '<leader>l', 'lrx'},
          },
          {
            prefix = 'g',
            { 'D', 'rgx'},
          },
          {
            mod = 'C',
            { 'x', 'rx'},
          },
          {'<C-r><C-r>', [[xyz]]},
        }
      }

      local api = mock(vim.api, true)

      cut.map(mappings)

      assert.stub(api.nvim_buf_set_keymap).was_called_with(456, 'i', '<leader><leader>l', 'lrx', { noremap = true })
      assert.stub(api.nvim_buf_set_keymap).was_called_with(456, 'n', '<leader><leader>l', 'lrx', { noremap = true, silent = true })
      assert.stub(api.nvim_buf_set_keymap).was_called_with(456, 'n', '<C-x>', 'rx', { noremap = true, silent = true })
      assert.stub(api.nvim_buf_set_keymap).was_called_with(456, 'n', 'gD', 'rgx', { noremap = true, silent = true })
      assert.stub(api.nvim_buf_set_keymap).was_called_with(456, 'n', '<C-r><C-r>', 'xyz', { noremap = true, silent = true })
      mock.revert(api)
    end)

    it("Should allow setting buffer at mode level", function()
      local mappings = {
        buffer = 0,
        n = {
          options = { silent = true},
          buffer = 123,
          {
            prefix = '<leader>',
            { '<leader>l', 'lrx'},
          },
          {
            prefix = 'g',
            { 'D', 'rgx'},
          },
          {
            mod = 'C',
            { 'x', 'rx'},
          },
        },
        i = {
          { 'xd', 'r'}
        }
      }

      local api = mock(vim.api, true)

      cut.map(mappings)

      assert.stub(api.nvim_buf_set_keymap).was_called_with(123, 'n', '<leader><leader>l', 'lrx', { noremap = true, silent = true })
      assert.stub(api.nvim_buf_set_keymap).was_called_with(123, 'n', '<C-x>', 'rx', { noremap = true, silent = true })
      assert.stub(api.nvim_buf_set_keymap).was_called_with(123, 'n', 'gD', 'rgx', { noremap = true, silent = true })
      assert.stub(api.nvim_buf_set_keymap).was_called_with(0, 'i', 'xd', 'r', { noremap = true })
      mock.revert(api)
    end)

    it("Should traverse all depths", function()
      local maps = {
        n = {
          options = { a = 'b'},
          { '<Space>', '<Nop>' },
          { '<tab>', 'za' },
          {
            mod = 'C',
            { 'h', '<C-w>h', { noremap = false } },
            { 'j', '<C-w>j', { expr = true, silent = true} },
            { 'k', '<C-w>k' },
            { 'l', '<C-w>l' },
          }
        },
        i = {
          options = { x = 'y'},
          { 'F', 'ab' },
        }
      }



      local api = mock(vim.api, true)

      cut.map(maps)

      assert.stub(api.nvim_set_keymap).was_called_with('n', '<Space>', '<Nop>', { a = 'b', noremap = true})
      assert.stub(api.nvim_set_keymap).was_called_with('n', '<tab>', 'za', { a = 'b', noremap = true})
      assert.stub(api.nvim_set_keymap).was_called_with('n', '<C-h>', '<C-w>h', { a = 'b', noremap = false })
      assert.stub(api.nvim_set_keymap).was_called_with('n', '<C-j>', '<C-w>j', { a = 'b', noremap = true, expr = true, silent = true })
      assert.stub(api.nvim_set_keymap).was_called_with('i', 'F', 'ab', { x = 'y', noremap = true })
      mock.revert(api)
    end)

    -- it("Should allow double bindings with modifier", function()
    --   local maps = {
    --     n = {
    --       {
    --         mod = 'C',
    --         { 'h', '<C-w>h' }
    --       }
    --     }
    --   }

    --   local api = mock(vim.api, true)

    --   cut.map(maps)

    --   assert.stub(api.nvim_set_keymap).was_called_with('n', '<C-h>', '<C-w>h', { noremap = true })
    --   mock.revert(api)
    -- end)

  end)
end)
