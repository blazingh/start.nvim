vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.scrolloff = 12
vim.o.number = true
vim.o.relativenumber = true
vim.o.clipboard = 'unnamedplus'
vim.o.termguicolors = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.laststatus = 3
vim.cmd([[highlight winseparator guifg=#FFFFFF guibg=NONE]])


local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>dn', vim.diagnostic.goto_prev, { desc = '[D]iagnostic [N]ext' })
vim.keymap.set('n', '<leader>dN', vim.diagnostic.goto_next, { desc = '[D]iagnostic previous' })
vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float, { desc = 'Open [D]iagnostic [F]loat' })
vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = '[D]iagnostic [L]ist' })

-- widow size adjustment
vim.keymap.set('n', '<A-left>', '<C-w><', { desc = 'Increase window size' })
vim.keymap.set('n', '<A-right>', '<C-w>>', { desc = 'Decrease window size' })
vim.keymap.set('n', '<A-up>', '<C-w>+', { desc = 'Increase window size' })
vim.keymap.set('n', '<A-down>', '<C-w>-', { desc = 'Decrease window size' })

-- buffer navigation
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>bx', ':bd<CR>', { desc = 'Close buffer' })


-- add format on save
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

require('lazy').setup({

  -- codeium for ai autocomplete
  {
    'Exafunction/codeium.vim',
    config = function()
      vim.keymap.set('i', '<C-right>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true })
      vim.keymap.set('i', '<C-left>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true })
      vim.keymap.set('i', '<C-x>', function() return vim.fn['codeium#Clear']() end, { expr = true })
    end
  },

  -- nightfox theme
  {
    'EdenEast/nightfox.nvim',
    opts = {
      options = {
        transparent = true,
      },
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },

  -- tree sitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "javascript", "go" },
        sync_install = false,
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },

  -- telescope
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch [G]rep' })
      vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = '[S]earch [B]uffers' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader><space>', builtin.current_buffer_fuzzy_find, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>s<CR>', builtin.resume, { desc = 'Telescope resume' })
    end
  },

  -- nvim-cmp for autocomplete
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      require('luasnip.loaders.from_vscode').lazy_load()
      cmp.setup {
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.scroll_docs(-4),
          ['<C-o>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = false }),
          ['<C-x>'] = cmp.mapping.abort(),
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        }
      }
    end
  },

  -- mason configuration
  {
    'williamboman/mason.nvim',
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
      'neovim/nvim-lspconfig',
    },
    config = function()
      require('mason').setup({
        ui = {
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗',
          }
        }
      })
      require('mason-lspconfig').setup {
        ensure_installed = {
          'tsserver',
          'lua_ls',
          'gopls',
          'html',
          'jsonls',
          'pyright',
        },
        automatic_installation = true,
      }
    end
  },

  -- lsp config
  {
    'neovim/nvim-lspconfig',
    env = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      { 'jose-elias-alvarez/null-ls.nvim', config = true },
      { 'j-hui/fidget.nvim',               tag = 'legacy', opts = {} },
    },
    config = function()
      local on_attach = function(_, bufnr)
        vim.keymap.set('n', '<leader>ld', vim.lsp.buf.definition, { buffer = bufnr, desc = '[l]sp [d]efinition' })
        vim.keymap.set('n', '<leader>lh', vim.lsp.buf.hover, { buffer = bufnr, desc = '[l]sp [h]over' })
        vim.keymap.set('n', '<leader>li', vim.lsp.buf.implementation, { buffer = bufnr, desc = '[l]sp [i]mplementation' })
        vim.keymap.set('n', '<leader>lt', vim.lsp.buf.type_definition,
          { buffer = bufnr, desc = '[l]sp [t]ype definition' })
        vim.keymap.set('n', '<leader>lr', vim.lsp.buf.references, { buffer = bufnr, desc = '[l]sp [r]eferences' })
        vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, { buffer = bufnr, desc = '[l]sp [f]ormat' })
      end
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      require('lspconfig').lua_ls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' }
            }
          }
        }
      }
      require('lspconfig').tsserver.setup {
        on_attach = on_attach,
        capabilities = capabilities
      }
      require('lspconfig').gopls.setup {
        on_attach = on_attach,
        capabilities = capabilities
      }
      require('lspconfig').html.setup {
        filetype = { 'html' },
        root_dir = function() return vim.loop.cwd() end,
        on_attach = on_attach,
        capabilities = capabilities
      }
      require('lspconfig').jsonls.setup {
        on_attach = on_attach,
        capabilities = capabilities
      }
      require('lspconfig').pyright.setup {
        on_attach = on_attach,
        capabilities = capabilities
      }
    end
  },

  -- lazy git
  {
    'kdheepak/lazygit.nvim',
    config = function()
      vim.keymap.set('n', '<leader>gg', ':LazyGit<CR>', { desc = 'LazyGit' })
    end
  },

  -- gitsigns for better git visibility
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>gN', require('gitsigns').prev_hunk,
          { buffer = bufnr, desc = '[G]it [P]revious Hunk' })
        vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk, { buffer = bufnr, desc = '[G]it [N]ext Hunk' })
        vim.keymap.set('n', '<leader>gp', require('gitsigns').preview_hunk,
          { buffer = bufnr, desc = '[G]it [P]review Hunk' })
        vim.keymap.set('n', '<leader>gb', require('gitsigns').blame_line, { buffer = bufnr, desc = '[G]it [B]lame' })
      end
    },
  },

  -- lualine status bar
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      for i = 1, 9 do
        vim.keymap.set('n', '<leader>' .. i, ':LualineBuffersJump! ' .. i .. '<CR>', { desc = 'Jump to buffer ' .. i })
      end
      require('lualine').setup({
        options = {
          globalstatus = true,
          icons_enabled = true,
          theme = 'auto',
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'diff', 'diagnostics' },
          lualine_c = {
            { 'buffers', mode = 2 },
          },
          lualine_x = {},
          lualine_y = { 'progress' },
          lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {}
      })
    end,
  },

  -- nvim file tree
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "antosha417/nvim-lsp-file-operations",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local function my_on_attach(bufnr)
        local api = require "nvim-tree.api"

        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- custom mappings
        vim.keymap.set('n', '<leader>fbm', api.marks.bulk.move, opts('Bulk Move Marks'))
        vim.keymap.set('n', '<leader>fbd', api.marks.bulk.delete, opts('Bulk Delete Marks'))
        vim.keymap.set('n', '<leader>fb', api.tree.toggle_help, opts('Help'))
        vim.keymap.set('n', 'q', api.tree.close, opts('[q]uit'))
      end

      require("nvim-tree").setup {
        on_attach = my_on_attach,
        sort_by = "case_sensitive",
        view = {
          width = function()
            return math.floor(vim.opt.columns:get() * 0.8)
          end,
          relativenumber = true,
          float = {
            enable = true,
            open_win_config = function()
              local screen_w = vim.opt.columns:get()
              local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
              local window_w = screen_w * 0.8
              local window_h = screen_h * 0.8
              local window_w_int = math.floor(window_w)
              local window_h_int = math.floor(window_h)
              local center_x = (screen_w - window_w) / 2
              local center_y = ((vim.opt.lines:get() - window_h) / 2)
                  - vim.opt.cmdheight:get()
              return {
                border = "rounded",
                relative = "editor",
                row = center_y,
                col = center_x,
                width = window_w_int,
                height = window_h_int,
              }
            end,
          },
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = true,
        },
      }
      require("lsp-file-operations").setup()
      vim.keymap.set('n', '<leader>ft', ':NvimTreeToggle<CR>', { desc = 'Toggle [F]ile [T]ree' })
      vim.keymap.set('n', '<leader>fc', ':NvimTreeFindFile<CR>', { desc = '[f]ind [c]urrent file' })
      vim.keymap.set('n', '<leader>fr', ':NvimTreeRefresh<CR>', { desc = '[f]ind [r]efresh' })
    end,
  }

})

-- set the theme
vim.cmd [[colorscheme carbonfox]]


--[=====[
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'tpope/vim-sleuth',
--]=====]
