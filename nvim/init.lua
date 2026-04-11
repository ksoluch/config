-- For  blink to work run 'cargo build --release' in ~/.local/share/nvim/site/pack/core/opt/blink.cmp

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set('n', 'S', '<Plug>(easymotion-s)', {
  silent = true, noremap = true, desc = "EasyMotion: Search All Character"
})

-- Options
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.clipboard:append("unnamedplus")
vim.opt.path:append("**")
vim.opt.colorcolumn = "120"
vim.opt.lazyredraw = true
vim.opt.autoread = true
vim.opt.foldlevel = 99
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Plugins
vim.pack.add({
  { src = 'https://github.com/saghen/blink.cmp.git' },
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/easymotion/vim-easymotion' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/nvim-telescope/telescope.nvim' },
  { src = 'https://github.com/Civitasv/cmake-tools.nvim' },
})

-- LSP Diagnostics
vim.diagnostic.config({
  virtual_text = true,
})

-- LSP Server Configurations
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
      format = { enable = true },
      scan_cmake_in_package = true,
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
    init_options = { fallbackFlags = { "-std=c++17" } },
    filetypes = { 'cpp', 'c', 'h', 'hpp' },
    root_markers = { '.clangd', 'compile_commands.json', '.git' },
  }
}

-- Apply configurations using blink.cmp capabilities
for server, config in pairs(configs) do
  local has_blink, blink = pcall(require, "blink.cmp")
  if has_blink then
    config.capabilities = blink.get_lsp_capabilities(config.capabilities)
  end

  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

-- blink.cmp Setup
require('blink.cmp').setup({
  keymap = {
    preset = 'default',
    ['<C-e>'] = { 'accept', 'fallback' },
    ['<C-j>'] = { 'select_next', 'fallback' },
    ['<C-k>'] = { 'select_prev', 'fallback' },
    ['<C-w>'] = { 'show', 'show_documentation', 'hide_documentation' },
    -- Scroll the doc window while staying in Insert mode
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
  },
  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = 'mono'
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  completion = {
    ghost_text = { enabled = true },
    menu = { auto_show = true },
    documentation = { 
      auto_show = true, 
      auto_show_delay_ms = 200,
      window = {
        max_width = 80,
        max_height = 20,
        border = 'rounded',
      }
    },
  }
})

-- Telescope & Mappings
local actions = require('telescope.actions')
local telescope = require("telescope")
telescope.setup({
  defaults = {
    layout_strategy = 'horizontal',
    layout_config = {
      horizontal = {
        width = 0.95,         -- 95% of screen width
        height = 0.85,        -- 85% of screen height
        preview_width = 0.5,  -- Split 50/50 between list and preview
        prompt_position = "bottom",
      },
    },
    -- path_display = { "smart" }, -- Shows the most relevant parts of the path
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
vim.keymap.set("n", "<leader>q", ":bd<CR>", { desc = "Close buffer" })
vim.keymap.set('n', '<leader>w', ":cd <C-r>=expand('%:p:h')<CR>", { desc = "cd to current file dir" })
vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>F', function()
  -- Get the directory of the current buffer's file
  local buffer_dir = vim.fn.expand('%:p:h')
  -- Type the command into the command line buffer
  -- We add the '/' at the end to make appending subfolders easier
  local cmd = ':Telescope find_files cwd=' .. buffer_dir .. '/'
  vim.api.nvim_feedkeys(cmd, 'n', false)
end, { desc = 'Telescope: Find files in current buffer directory' })
vim.keymap.set('n', '<leader>g', builtin.live_grep, { desc = 'Live grep' })
-- vim.keymap.set('n', '<leader>G', ":Telescope live_grep glob_pattern=", { desc = 'Telescope live grep some files' })
vim.keymap.set('n', '<leader>G', ":Telescope live_grep glob_pattern=!**/*test*<Left>", { desc = 'Telescope live grep excluding test files' })
vim.keymap.set('n', 'grd', vim.lsp.buf.definition, { desc = 'Go to Definition' })
vim.keymap.set('n', 'gr', function()
  require('telescope.builtin').lsp_references({
    include_declaration = true,
    show_line = true,
    jump_type = "never", -- Prevents jumping if only one result is found
  })
end, { desc = "LSP References (Telescope)" })
-- Path copy utility
vim.keymap.set('n', '<leader>p', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path)
  print("Copied path: " .. path)
end, { desc = 'Copy current file path' })

require("cmake-tools").setup({
  cmake_build_directory = "build",
})
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Telescope the oppen buffers' })
vim.keymap.set('n', '<leader>r', builtin.current_buffer_fuzzy_find, { desc = 'Telescope the content of the current buffer' })
vim.keymap.set('n', '<leader>t', function()
  builtin.live_grep({
    grep_open_files = true,
  })
end, { desc = 'Telescope the content of the open buffers' })
vim.keymap.set('n', '<leader>a', function() vim.lsp.buf.code_action() end, { desc = 'Rust Code Actions' })
