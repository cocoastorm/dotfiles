-- automatically install packer
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

-- autocommand that reloads neovim whenever you save the plugins.lua file
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', { command = 'source <afile> | PackerCompile', group = packer_group, pattern = 'init.lua' })

require('packer').startup({function()
  use 'wbthomason/packer.nvim' -- Package manager

  -- used by a lot of lua plugins
  use 'nvim-lua/plenary.nvim'
  use 'nvim-lua/popup.nvim'

  -- editorconfig
  use 'gpanders/editorconfig.nvim'

  -- lsp config
  use 'b0o/schemastore.nvim'

  use {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig',

    -- linting for non-lsp servers
    'jose-elias-alvarez/null-ls.nvim',
  }

  -- autocompletion
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'

  -- content
  -- vipga/gaip to start interactive EasyAlign
  use 'junegunn/vim-easy-align'
  use 'numToStr/Comment.nvim' -- "gc" to comment visual regions/lines
  use 'lukas-reineke/indent-blankline.nvim' -- add indentation guides even on blank lines 

  use 'folke/lsp-colors.nvim'

  use {
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
  }

  -- statusline
  use 'nvim-lualine/lualine.nvim' -- fancier statusline

  -- snippets
  use 'hrsh7th/cmp-vsnip'
  use 'hrsh7th/vim-vsnip'

  -- git and spellcheck
  use 'lewis6991/gitsigns.nvim'
  use 'lewis6991/spellsitter.nvim'

  -- treesitter
  -- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function() require('nvim-treesitter.install').update({ with_sync = true}) end,
  }
  use 'nvim-treesitter/nvim-treesitter-textobjects'

  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      {'kyazdani42/nvim-web-devicons'},
    },
  }

  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      {'nvim-telescope/telescope-fzf-native.nvim', run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'}
    },
  }

  use 'marko-cerovac/material.nvim'

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end,
config = {
  display = {
    open_fn = function ()
      return require('packer.util').float({ border = 'single' })
    end
  }
}})

-- colors and font
vim.opt.termguicolors = true
vim.opt.guifont = 'JetBrainsMono Nerd Font Mono:h11'

-- use filetype.lua
-- see https://github.com/neovim/neovim/pull/16600
-- vim.g.do_filetype_lua = 1
-- vim.g.do_did_load_filetypes = 0

-- remap space as leader key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

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
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- list chars
vim.opt.list = true
vim.opt.listchars:append("space:⋅")
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

-- material theme
vim.g.material_style = 'deep ocean'

require('material').setup({
  contrast = {
    terminal = false,
    sidebars = true,
    float_windows = true,
    cursor_line = true,
    non_current_windows = true,
  },

  plugins = {
    "gitsigns",
    "indent-blankline",
    "nvim-cmp",
    "nvim-tree",
    "telescope",
    "trouble",
  },
})

vim.cmd 'colorscheme material'

-- lsp, completion, and nvim-treesitter
local servers = {
  "bashls",
  "cssls",
  "pyright",
  "rust_analyzer",
  "sumneko_lua",
  "taplo",
  "yamlls",
}

-- mason.nvim
require('mason').setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

require('mason-lspconfig').setup{}

-- autocompletion
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
    ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
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
    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>so', '<cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>f', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', opts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches

-- autocompletion with lsp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local nvim_lsp = require('lspconfig')

require'mason-lspconfig'.setup_handlers {
  -- the first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler
  function (server_name) -- default handler
    nvim_lsp[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
    }
  end,

  -- jsonls
  ["jsonls"] = function ()
    nvim_lsp.jsonls.setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        json = {
          schemas = require('schemastore').json.schemas {
            ignore = {
              '.eslintrc',
              'package.json',
            },
          },
          validate = { enable = true },
        }
      }
    }
  end,

  -- typescript
  ["tsserver"] = function ()
    nvim_lsp.tsserver.setup {
      capabilities = capabilities,
      on_attach = on_attach,
    }
  end,

  ["volar"] = function ()
    nvim_lsp.volar.setup {
      capabilities = capabilities,
      on_attach = on_attach,
    }
  end,

  -- intelephense
  ["intelephense"] = function ()
    nvim_lsp.intelephense.setup {
      capabilities = capabilities,
      on_attach = on_attach,
      init_options = { licenceKey = vim.fn.stdpath('config')..'/intelephense-license.txt' },
    }
  end,

  -- psalm
  ["psalm"] = function ()
    nvim_lsp.psalm.setup {
      capabilities = capabilities,
      on_attach = on_attach,
      root_dir = nvim_lsp.util.root_pattern("composer.json", "psalm.xml")
    }
  end,

  -- gopls
  ["gopls"] = function ()
    nvim_lsp.gopls.setup {
      capabilities = capabilities,
      on_attach = on_attach,
      cmd = {"gopls", "serve"},
      root_dir = nvim_lsp.util.root_pattern("go.mod"),
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
          },
          staticcheck = true,
        },
      },
    }
  end,
}

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

-- golang: imports
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   pattern = { "*.go" },
--   callback = vim.lsp.buf.format,
-- })

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function ()
    local params = vim.lsp.util.make_range_params()
    params.context = {only = {"source.organizeImports"}}
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 5000)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc) 
        else
          vim.lsp.buf.execute_command(r.command)
        end
      end
    end
  end,
})

-- nvim lsp: disable virtual text
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    virtual_text = function(namespace, bufnr)
      return vim.b[bufnr].show_virtual_text == true
    end,
    signs = true,
    update_in_insert = false
  }
)

vim.api.nvim_create_autocmd('FileType', {
  pattern = '*.go',
  callback = function () vim.api.nvim_command('setlocal omnifunc=v:lua.vim.lsp.omnifunc') end,
})

-- trouble.nvim
require'trouble'.setup {}

 -- treesitter
 require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    'html',
    'css',
    'scss',
    'javascript',
    'typescript',
    'json',
    'lua',
    'go',
    'php',
    'rust',
    'toml',
    'vue',
    'yaml',
  },

  highlight = {
    enable = true,
    disable = { "toml", "yaml", "vim" }, -- disabling toml and yaml because their parsers are causing crashes on Windows. :upside_down:
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
   },
   indent = {
    enable = true,
    disable = { 'yaml' }
   },
   textobjects = {
    select = {
      enable = true,
      lookahead = true, -- automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
   },
 }

-- nvimtree
require'nvim-web-devicons'.setup()
require'nvim-tree'.setup({
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = true,
  },
})

-- statusbar
require('lualine').setup {
  options = {
    icons_enable = false,
    theme = 'material',
    component_separators = '|',
    section_separators = '',
  },
  disabled_filetypes = { 'packer' },
  extensions = { 'nvim-tree' },
}

-- enable Comment.nvim
require('Comment').setup()

-- indent blankline
require('indent_blankline').setup {
  char = '┊',
  show_trailing_blankline_indent = false,
  space_char_blankline = " ",
  show_current_context = true,
  show_current_context_start = true,
}

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
local trouble = require('trouble.providers.telescope')

local telescope = require('telescope')

telescope.setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ['<C-t>'] = trouble.open_with_trouble,
      },
      n = {
        ['<C-t>'] = trouble.open_with_trouble,
      },
    },
  },
}

-- add leader shortcuts with telescope
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

-- keymaps
-- <esc> as double ;
vim.api.nvim_set_keymap('x', ';;', '<esc>', opts)

-- nvim-tree
vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>r', ':NvimTreeRefresh', opts)
vim.api.nvim_set_keymap('n', '<leader>n', ':NvimTreeFindFile', opts)

-- trouble.nvim
vim.api.nvim_set_keymap('n', '<leader>xx', '<cmd>Trouble<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>xw', '<cmd>Trouble workspace_diagnostics<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>xd', '<cmd>Trouble document_diagnostics<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>xl', '<cmd>Trouble loclist<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>xq', '<cmd>Trouble quickfix<cr>', opts)
vim.api.nvim_set_keymap('n', 'gR', '<cmd>Trouble lsp_references<cr>', opts)

-- easy align
local easy_align_opts = { noremap = false, silent = true }
vim.api.nvim_set_keymap('n', 'ga', '<Plug>(EasyAlign)', easy_align_opts)
vim.api.nvim_set_keymap('x', 'ga', '<Plug>(EasyAlign)', easy_align_opts)

