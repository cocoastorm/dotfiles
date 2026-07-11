-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key (must be set before plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.mouse = "a"
vim.opt.breakindent = true
vim.opt.showmatch = true
vim.opt.laststatus = 3

-- Spell check for relevant filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "gitcommit" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})

-- Disable hard line wrapping in git commit messages
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.textwidth = 100
  end,
})

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local lsp_servers = { "bashls", "jsonls", "taplo", "yamlls" }
local mason_lsp_servers = vim.deepcopy(lsp_servers)
if vim.fn.executable("go") == 1 or vim.fn.executable("gopls") == 1 then
  table.insert(lsp_servers, "gopls")
  table.insert(mason_lsp_servers, "gopls")
end

-- Plugins
require("lazy").setup({
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },

  -- Theme: Night Owl (port of Sarah Drasner's VS Code Night Owl)
  {
    "oxfist/night-owl.nvim",
    name = "night-owl",
    lazy = false,
    priority = 1000,
    config = function()
      require("night-owl").setup({
        bold = true,
        italics = true,
        underline = true,
        undercurl = true,
        transparent_background = false,
      })
      vim.cmd.colorscheme("night-owl")

      -- Re-apply overrides whenever this colorscheme is (re)loaded.
      local function apply_night_owl_overrides()
        -- Canonical Night Owl background is #011627; the port uses #021727.
        vim.api.nvim_set_hl(0, "Normal", { fg = "#d6deeb", bg = "#011627" })
        -- Plain @keyword (const/import/let/var/...) should be italic like the
        -- screenshot; the port leaves it non-italic (only Statement links are).
        vim.api.nvim_set_hl(0, "Keyword", { fg = "#c792ea", bg = "NONE", italic = true })
        vim.api.nvim_set_hl(0, "@keyword", { fg = "#c792ea", bg = "NONE", italic = true })
      end
      apply_night_owl_overrides()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("NightOwlOverrides", { clear = true }),
        pattern = "night-owl",
        callback = apply_night_owl_overrides,
      })
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "night-owl" },
      })
    end,
  },

  -- Tree-sitter parsers and native Neovim highlighting (requires Neovim 0.12+).
  {
    "neovim-treesitter/nvim-treesitter",
    dependencies = { "neovim-treesitter/treesitter-parser-registry" },
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local parsers = {
        "bash",
        "go",
        "lua",
        "markdown",
        "markdown_inline",
        "gitcommit",
        "python",
        "json",
        "yaml",
        "toml",
        "javascript",
        "typescript",
        "tsx",
      }

      -- The 0.12 rewrite installs parsers and queries separately from highlighting.
      require("nvim-treesitter").install(parsers)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = parsers,
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>ft", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        window = {
          width = 30,
          mappings = {
            ["<cr>"] = "open",
            ["s"] = "open_vsplit",
            ["S"] = "open_split",
            ["t"] = "open_tabnew",
            ["h"] = "toggle_hidden",
            ["<bs>"] = "navigate_up",
            ["."] = "set_root",
            ["H"] = "toggle_hidden",
            ["/"] = "fuzzy_finder",
            ["D"] = "fuzzy_finder_directory",
            ["#"] = "fuzzy_sorter",
            ["<c-r>"] = "clear_filter",
            ["a"] = { "add", config = { show_path = "relative" } },
            ["c"] = { "copy", config = { show_path = "relative" } },
            ["m"] = { "move", config = { show_path = "relative" } },
            ["r"] = "rename",
            ["d"] = "delete",
            ["y"] = "copy_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
          },
        },
        filesystem = {
          filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = true,
          },
          follow_current_file = {
            enabled = true,
          },
          use_libuv_file_watcher = true,
        },
      })
    end,
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers,    { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep,  { desc = "Live grep" })
    end,
  },

  -- Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Comment toggling
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- LSP server installer/configs
  "neovim/nvim-lspconfig",
  "b0o/schemastore.nvim",
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = mason_lsp_servers,
        automatic_enable = false,
      })
    end,
  },
}, {
  ui = { border = "rounded" },
})

-- LSP setup using Neovim's native vim.lsp.config/enable APIs.
vim.lsp.config("jsonls", {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
})

vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      schemaStore = { enable = false, url = "" },
      schemas = require("schemastore").yaml.schemas(),
    },
  },
})

vim.lsp.config("gopls", {
  settings = {
    gopls = {
      analyses = { unusedparams = true },
      staticcheck = true,
    },
  },
})

-- Go: organize imports and format before saving.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("GoFormat", { clear = true }),
  pattern = "*.go",
  callback = function(args)
    if #vim.lsp.get_clients({ bufnr = args.buf, name = "gopls" }) == 0 then
      return
    end

    local params = {
      textDocument = vim.lsp.util.make_text_document_params(args.buf),
      range = {
        start = { line = 0, character = 0 },
        ["end"] = { line = vim.api.nvim_buf_line_count(args.buf), character = 0 },
      },
      context = { only = { "source.organizeImports" }, diagnostics = {} },
    }

    local results = vim.lsp.buf_request_sync(args.buf, "textDocument/codeAction", params, 3000)
    for client_id, result in pairs(results or {}) do
      for _, action in pairs(result.result or {}) do
        if action.edit then
          local client = vim.lsp.get_client_by_id(client_id)
          local encoding = client and client.offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(action.edit, encoding)
        end
        if action.command then
          vim.lsp.buf.execute_command(action.command)
        end
      end
    end

    vim.lsp.buf.format({
      bufnr = args.buf,
      async = false,
      timeout_ms = 3000,
      filter = function(client)
        return client.name == "gopls"
      end,
    })
  end,
})

vim.lsp.enable(lsp_servers)

-- LSP keymaps on attach
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(args)
    local opts = { buffer = args.buf, noremap = true, silent = true }
    vim.keymap.set("n", "K",          vim.lsp.buf.hover,           opts)
    vim.keymap.set("n", "gd",         vim.lsp.buf.definition,      opts)
    vim.keymap.set("n", "gD",         vim.lsp.buf.declaration,     opts)
    vim.keymap.set("n", "gi",         vim.lsp.buf.implementation,  opts)
    vim.keymap.set("n", "gr",         vim.lsp.buf.references,      opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,          opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,     opts)
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})

-- Diagnostics
vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { noremap = true, silent = true, desc = "Diagnostic float" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { noremap = true, silent = true })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { noremap = true, silent = true })

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
