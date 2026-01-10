-- Options are automatically loaded before lazy.nvim startup
-- Default options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

-- General
opt.autowrite = true          -- Enable auto write
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.confirm = true            -- Confirm to save changes before exiting
opt.cursorline = true         -- Enable highlighting of the current line
opt.mouse = "a"               -- Enable mouse mode
opt.number = true             -- Print line number
opt.relativenumber = true     -- Relative line numbers
opt.scrolloff = 8             -- Lines of context
opt.sidescrolloff = 8         -- Columns of context
opt.signcolumn = "yes"        -- Always show the signcolumn
opt.termguicolors = true      -- True color support
opt.wrap = false              -- Disable line wrap

-- Indentation
opt.expandtab = true          -- Use spaces instead of tabs
opt.shiftround = true         -- Round indent
opt.shiftwidth = 2            -- Size of an indent
opt.smartindent = true        -- Insert indents automatically
opt.tabstop = 2               -- Number of spaces tabs count for

-- Search
opt.ignorecase = true         -- Ignore case
opt.smartcase = true          -- Don't ignore case with capitals
opt.hlsearch = true           -- Highlight search results
opt.incsearch = true          -- Show search matches as you type

-- Splits
opt.splitbelow = true         -- Put new windows below current
opt.splitright = true         -- Put new windows right of current

-- Undo
opt.undofile = true           -- Save undo history
opt.undolevels = 10000

-- Performance
opt.updatetime = 200          -- Save swap file and trigger CursorHold
opt.timeoutlen = 300          -- Time to wait for a mapped sequence

-- Completion
opt.completeopt = "menu,menuone,noselect"
opt.pumblend = 10             -- Popup blend
opt.pumheight = 10            -- Maximum number of entries in a popup

-- Folding (using treesitter)
opt.foldlevel = 99
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Disable some default providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
