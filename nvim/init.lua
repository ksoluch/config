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
  { src = 'https://github.com/Civitasv/cmake-tools.nvim' },
}

vim.diagnostic.config({
-- virtual_lines = true,
virtual_text = true,
})

-- 1. Define your configurations in a local table for better organization
local configs = {
  rust_analyzer = {
    settings = {
      ['rust-analyzer'] = {
        checkOnSave = true,
        cargo = { allFeatures = true },
        procMacro = { enable = true },
      },
    },
  },
  pyright = {
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace",
          typeCheckingMode = "basic",
        },
      },
    },
  },
  neocmakelsp = {
    cmd = { "neocmakelsp", "stdio" },
    filetypes = { "cmake" },
    root_markers = { "CMakeLists.txt", ".git" },
    init_options = {
      format = {
        enable = true,
      },
      scan_cmake_in_package = true, -- Helps with finding package completions
    }
  },
  clangd = {
    cmd = {
      'clangd-20',
      "--background-index",
      "--clang-tidy",
      "--all-scopes-completion",
      "--completion-style=detailed",
      "--compile-commands-dir=/home/soluch01/w/p4-device-software-definition/build",
    },
    init_options = {
      fallbackFlags = { "-std=c++17" },
    },
    filetypes = { 'cpp', 'c', 'h', 'hpp' },
    root_markers = { '.clangd', 'compile_commands.json', '.git' },
    capabilities = {
      textDocument = {
        semanticTokens = {
          multilineTokenSupport = true,
        }
      }
    },
  }
}

-- 2. Loop through and apply them using the native API
for server, config in pairs(configs) do
  -- Inject nvim-cmp capabilities if the plugin is available
  local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if has_cmp then
    config.capabilities = vim.tbl_deep_extend(
      "force",
      config.capabilities or {},
      cmp_lsp.default_capabilities()
    )
  end

  -- Register the config (Function call, not table assignment)
  vim.lsp.config(server, config)
  
  -- Enable the server
  vim.lsp.enable(server)
end

require("cmake-tools").setup({
  cmake_build_directory = "build",
  cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
})

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
vim.keymap.set("n", "<leader>q", ":bd<CR>", { desc = "Close the current buffer" })
vim.keymap.set('n', '<leader>w', ":cd <C-r>=expand('%:p:h')<CR>", { desc = "Pre-fill cd with current buffer directory" })
vim.keymap.set("n", "<leader>e", ":edit %:p:h<CR>", { desc = "Print current file directory" })
vim.keymap.set('n', '<leader>a', function() vim.lsp.buf.code_action() end, { desc = 'Rust Code Actions' })
vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>g', builtin.live_grep, { desc = 'Telescope live grep all files' })
vim.keymap.set('n', '<leader>G', ":Telescope live_grep glob_pattern=", { desc = 'Telescope live grep some files' })
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Telescope the oppen buffers' })
vim.keymap.set('n', '<leader>r', builtin.current_buffer_fuzzy_find, { desc = 'Telescope the content of the current buffer' })
vim.keymap.set('n', '<leader>t', function()
  builtin.live_grep({
    grep_open_files = true,
  })
end, { desc = 'Telescope the content of the open buffers' })
vim.keymap.set('n', 'grD', vim.lsp.buf.declaration, { desc = 'Go to Declaration' })
vim.keymap.set('n', 'grd', vim.lsp.buf.definition, { desc = 'Go to Definition' })
vim.keymap.set('n', '<leader>p', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path)
  print("Copied path: " .. path)
end, { desc = 'Copy current file path' })
vim.keymap.set('n', '<leader>F', function()
  -- Get the directory of the current buffer's file
  local buffer_dir = vim.fn.expand('%:p:h')
  -- Type the command into the command line buffer
  -- We add the '/' at the end to make appending subfolders easier
  local cmd = ':Telescope find_files cwd=' .. buffer_dir .. '/'
  vim.api.nvim_feedkeys(cmd, 'n', false)
end, { desc = 'Telescope: Find files in current buffer directory' })
