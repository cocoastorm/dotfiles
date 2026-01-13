-- remap space as leader key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { 'marko-cerovac/material.nvim', lazy = false, priority = 1000, opts = {} },
  'folke/which-key.nvim',

  -- editorconfig
  'gpanders/editorconfig.nvim',

  -- lsp config
  'b0o/schemastore.nvim',

  -- Mason for LSP server management
  'williamboman/mason.nvim',
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'neovim/nvim-lspconfig' },
  },
  'neovim/nvim-lspconfig',

  -- linting for non-lsp servers
  'nvimtools/none-ls.nvim',

  -- autocompletion
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/nvim-cmp',

  -- vipga/gaip to start interactive EasyAlign
  'junegunn/vim-easy-align',
  -- "gc" to comment visual regions/lines
  'numToStr/Comment.nvim',
  -- add indentation guides even on blank lines
  { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },

  'folke/lsp-colors.nvim',
  'folke/trouble.nvim',

  -- fancier statusline
  'nvim-lualine/lualine.nvim',

  -- snippets
  'hrsh7th/cmp-vsnip',
  'hrsh7th/vim-vsnip',

  -- git and spellcheck
  'lewis6991/gitsigns.nvim',
  'lewis6991/spellsitter.nvim',

  -- treesitter
  -- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#lazynvim
  {
    'nvim-treesitter/nvim-treesitter',
    build = function ()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
    end,
    config = function ()
      local configs = require('nvim-treesitter.configs')
    	configs.setup({
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
          },
         }
       })
    end
  },

  -- neo-tree.nvim
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>ft", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
    },
    config = function ()
      require("neo-tree").setup()
    end,
  },

  -- telescope.nvim
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' },
    },
  },
})


-- colors and font
vim.opt.termguicolors = true
vim.opt.guifont = 'JetBrainsMono Nerd Font Mono:h11'

-- enable mouse
vim.opt.mouse = 'a'

-- basic settings
vim.opt.encoding = 'utf-8'
vim.opt.backspace = 'indent,eol,start'
vim.opt.completeopt = 'menuone,noselect'
vim.opt.startofline = true

-- display
vim.opt.showmatch = true
vim.opt.laststatus = 3

-- white characters
vim.opt.autoindent = false 
vim.opt.smartindent = true
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- list chars
vim.opt.list = true
vim.opt.listchars:append("space:·")
vim.opt.listchars:append("eol:↴")

-- highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})


require('material').setup({
  contrast = {
    terminal = false,
    sidebars = true,
    float_windows = true,
    cursor_line = true,
    non_current_windows = true,
  },

  plugins = {
    'gitsigns',
    'indent-blankline',
    'nvim-cmp',
    'telescope',
    'trouble',
  }
})
vim.g.material_style = "deep ocean"

vim.cmd[[colorscheme material]]

-- ============================================================================
-- MASON & LSP SETUP (Updated for Mason 2.0 and Neovim 0.11+)
-- ============================================================================

-- 1. Setup Mason
require('mason').setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

-- 2. Setup Mason-LSPConfig with servers to auto-install
require('mason-lspconfig').setup({
  ensure_installed = {
    'bashls',
    'jsonls',
    'taplo',
    'yamlls',
    'pyright',
    'gopls',
    'rust_analyzer',
  },
  automatic_installation = false,
})

-- 3. Get capabilities for nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- 4. Global LSP configuration for all servers
vim.lsp.config('*', {
  capabilities = capabilities,
})

-- 5. Configure specific LSP servers using vim.lsp.config()

-- Bash
vim.lsp.config('bashls', {
  filetypes = { 'sh', 'bash' },
})

-- JSON with schemastore
vim.lsp.config('jsonls', {
  settings = {
    json = {
      schemas = require('schemastore').json.schemas({
        ignore = {
          '.eslintrc',
          'package.json',
        },
      }),
      validate = { enable = true },
    }
  }
})

-- TOML
vim.lsp.config('taplo', {
  filetypes = { 'toml' },
})

-- YAML
vim.lsp.config('yamlls', {
  settings = {
    yaml = {
      schemas = {},
    }
  }
})

-- Python
vim.lsp.config('pyright', {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})

-- Go
vim.lsp.config('gopls', {
  cmd = {"gopls", "serve"},
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
})

-- Rust
vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = {
        command = "clippy"
      },
    },
  },
})

-- TypeScript (if you have tsserver/ts_ls)
-- vim.lsp.config('ts_ls', {})

-- Vue (if you have volar)
-- Note: For Vue with TypeScript plugin, you'll need to set up the plugin path
-- local vue_ls_path = vim.fn.expand("$MASON/packages/vue-language-server")
-- local vue_plugin_path = vue_ls_path .. "/node_modules/@vue/language-server"
-- vim.lsp.config('ts_ls', {
--   init_options = {
--     plugins = {
--       {
--         name = "@vue/typescript-plugin",
--         location = vue_plugin_path,
--         languages = { "vue" },
--       },
--     },
--   },
--   filetypes = { "typescript", "javascript", "vue" },
-- })

-- PHP Intelephense (if you use it)
-- vim.lsp.config('intelephense', {
--   init_options = { 
--     licenceKey = vim.fn.stdpath('config')..'/intelephense-license.txt' 
--   },
-- })

-- PHP Psalm
-- vim.lsp.config('psalm', {
--   root_dir = function(fname)
--     return vim.fs.dirname(vim.fs.find({'composer.json', 'psalm.xml'}, { upward = true })[1])
--   end
-- })

-- 6. Enable all configured LSP servers
-- This tells Neovim to auto-start these servers when appropriate filetypes are opened
vim.lsp.enable({
  'bashls',
  'jsonls', 
  'taplo',
  'yamlls',
  'pyright',
  'gopls',
  'rust_analyzer',
  -- Add any other servers you want to enable
})

-- 7. LSP keymaps and on_attach replacement
-- In Neovim 0.11+, use LspAttach autocmd instead of on_attach
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local bufnr = ev.buf
    local opts = { buffer = bufnr, noremap = true, silent = true }
    
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>so', function()
      require("telescope.builtin").lsp_document_symbols()
    end, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})

-- ============================================================================
-- AUTOCOMPLETION (nvim-cmp)
-- ============================================================================

local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
  }, {
    { name = 'buffer' },
  })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' },
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/`
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':'
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- ============================================================================
-- DIAGNOSTICS
-- ============================================================================

-- Diagnostic keymaps
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

-- Configure diagnostic display
vim.diagnostic.config({
  virtual_text = false,  -- Disable inline diagnostic text by default
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- ============================================================================
-- NULL-LS (none-ls)
-- ============================================================================

local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    null_ls.builtins.completion.spell,

    -- stylua
    null_ls.builtins.formatting.stylua.with({
      condition = function (utils)
        return utils.root_has_file({ "stylua.toml", ".stylua.toml" })
      end,
    }),

    -- phpcs
    null_ls.builtins.diagnostics.phpcs.with({
      prefer_local = 'vendor/bin',
      condition = function (utils)
        return utils.root_has_file({ "composer.json", "phpcs.xml" })
      end,
    }),
  }
})

-- ============================================================================
-- OTHER PLUGIN CONFIGS
-- ============================================================================

-- trouble.nvim
require'trouble'.setup {}

-- statusbar
require('lualine').setup {
  options = {
    icons_enable = false,
    theme = 'material',
    component_separators = '|',
    section_separators = '',
  },
}

-- enable Comment.nvim
require('Comment').setup()

-- indent blankline
require('ibl').setup { indent = { char = '┊' }}

-- gitsigns
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}

-- Telescope
local actions = require('telescope.actions')
local open_with_trouble = require('trouble.sources.telescope').open

local telescope = require('telescope')

telescope.setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ['<C-t>'] = open_with_trouble,
      },
      n = {
        ['<C-t>'] = open_with_trouble,
      },
    },
  },
}

-- ============================================================================
-- KEYMAPS
-- ============================================================================

-- telescope shortcuts
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers)
vim.keymap.set('n', '<leader>sf', function ()
  require('telescope.builtin').find_files { previewer = false }
end)
vim.keymap.set('n', '<leader>sb', require('telescope.builtin').current_buffer_fuzzy_find)
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags)
vim.keymap.set('n', '<leader>st', require('telescope.builtin').tags)
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').grep_string)
vim.keymap.set('n', '<leader>sp', require('telescope.builtin').live_grep)
vim.keymap.set('n', '<leader>so', function()
  require('telescope.builtin').tags { only_current_buffer = true }
end)
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles)

-- <esc> as double ;
vim.keymap.set('x', ';;', '<esc>', opts)

-- trouble.nvim
vim.keymap.set('n', '<leader>xx', '<cmd>Trouble<cr>', opts)
vim.keymap.set('n', '<leader>xw', '<cmd>Trouble workspace_diagnostics<cr>', opts)
vim.keymap.set('n', '<leader>xd', '<cmd>Trouble document_diagnostics<cr>', opts)
vim.keymap.set('n', '<leader>xl', '<cmd>Trouble loclist<cr>', opts)
vim.keymap.set('n', '<leader>xq', '<cmd>Trouble quickfix<cr>', opts)
vim.keymap.set('n', 'gR', '<cmd>Trouble lsp_references<cr>', opts)

-- easy align
local easy_align_opts = { noremap = false, silent = true }
vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)', easy_align_opts)
vim.keymap.set('x', 'ga', '<Plug>(EasyAlign)', easy_align_opts)
