vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set('n', 'S', '<Plug>(easymotion-s)', {
  silent = true, noremap = true, desc = "EasyMotion: Search All Character"
})

vim.opt.termguicolors = true                       -- Enable 24-bit colors
vim.opt.number = true                              -- Line numbers
vim.opt.relativenumber = true                      -- Relative line numbers
vim.opt.cursorline = true                          -- Highlight current line
vim.opt.wrap = false                               -- Don't wrap lines
vim.opt.scrolloff = 10                             -- Keep 10 lines above/below cursor 
vim.opt.sidescrolloff = 8                          -- Keep 8 columns left/right of cursor
vim.opt.tabstop = 2                                -- Tab width
vim.opt.shiftwidth = 2                             -- Indent width
vim.opt.softtabstop = 2                            -- Soft tab stop
vim.opt.expandtab = true                           -- Use spaces instead of tabs
vim.opt.smartindent = true                         -- Smart auto-indenting
vim.opt.autoindent = true                          -- Copy indent from current line
vim.opt.clipboard:append("unnamedplus")            -- Use system clipboard
vim.opt.path:append("**")                          -- include subdirectories in search
vim.opt.colorcolumn = "120"                        -- Show column at 100 characters
vim.opt.lazyredraw = true                          -- Don't redraw during macros
vim.opt.autoread = true                            -- Auto reload files changed outside vim
vim.opt.foldlevel = 99                             -- Start with all folds open
vim.opt.splitbelow = true                          -- Horizontal splits go below
vim.opt.splitright = true                          -- Vertical splits go right

vim.pack.add{
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = "https://github.com/hrsh7th/nvim-cmp.git" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp.git" },
  { src = "https://github.com/hrsh7th/cmp-buffer.git" },
  { src = "https://github.com/saghen/blink.cmp.git" },
  { src = 'https://github.com/easymotion/vim-easymotion' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/nvim-telescope/telescope.nvim' },
}

vim.lsp.config['clangd'] = {
  cmd = {
    'clangd',
    "--background-index",
    "--clang-tidy",
    -- "--log=verbose",
  },
  init_options = {
    fallbackFlags = { "-std=c++17" },
  },
  filetypes = { 'cpp', 'c', 'h' },
  root_markers = { '.clangd', 'compile_commands.json', '.git' },
  capabilities = {
    textDocument = {
      semanticTokens = {
        multilineTokenSupport = true,
      }
    }
  },
}

local servers = { "clangd" }
for _, server in ipairs(servers) do
    vim.lsp.config(server, {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        settings = {},
    })
    vim.lsp.enable(server)
end
vim.keymap.set('n', 'grd', vim.lsp.buf.declaration, { desc = 'Go to Declaration' })

local cmp = require("cmp")
cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ["<C-e>"] = cmp.mapping.confirm({ select = true }),
        ['<C-w>'] = cmp.mapping.complete(),
        ['<C-q>'] = cmp.mapping.abort(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-k>"] = cmp.mapping.select_prev_item(),
    }),
    sources = {
        { name = "nvim_lsp" },
        { name = "buffer" },
    },
    experimental = { ghost_text = true },
})
pcall(require, "blink.cmp")

local actions = require('telescope.actions')
local telescope = require("telescope")
telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.move_selection_next,
      },
    },
    -- configure to use ripgrep
    vimgrep_arguments = {
      "rg",
      "--follow",        -- Follow symbolic links
      "--hidden",        -- Search for hidden files
      "--no-heading",    -- Don't group matches by each file
      "--with-filename", -- Print the file path with the matched lines
      "--line-number",   -- Show line numbers
      "--column",        -- Show column numbers
      "--smart-case",    -- Smart case search
      -- Exclude some patterns from search
      "--glob=!**/.git/*",
      "--glob=!**/.idea/*",
      "--glob=!**/build/*",
      "--glob=!**/obj/*",
    },
  },
  pickers = {
    find_files = {
      hidden = true,
      -- needed to exclude some files & dirs from general search
      -- when not included or specified in .gitignore
      find_command = {
        "rg",
        "--follow",
        "--files",
        "--hidden",
        -- Exclude some patterns from search
        "--glob=!**/.git/*",
        "--glob=!**/build/*",
        "--glob=!**/obj/*",
      },
    },
  },
})
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>g', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>r', builtin.current_buffer_fuzzy_find, { desc = 'Telescope buffers' })
