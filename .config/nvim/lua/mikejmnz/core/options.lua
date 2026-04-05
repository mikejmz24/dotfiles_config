local opt = vim.opt

-- Line numbers
opt.number = true
-- opt.relativenumber = true

-- Tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- Line wrapping
opt.wrap = false

-- Scrolling context
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split" -- live preview of substitutions

-- Cursor
opt.cursorline = true

-- Appearance
opt.termguicolors = true

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Performance
opt.updatetime = 250 -- faster diagnostics and CursorHold
opt.timeoutlen = 300 -- faster which-key popup
opt.redrawtime = 10000 -- allow more time for syntax highlighting on large files
opt.synmaxcol = 240 -- limit syntax highlighting for very long lines

-- File handling
opt.autoread = true -- auto reload files changed outside nvim
opt.autowrite = true -- auto write when switching buffers
opt.confirm = true -- confirm instead of erroring on unsaved changes

-- Completion
opt.completeopt = "menu,menuone,noselect" -- preview removed: conflicts with nvim-cmp docs
opt.pumheight = 10

-- Sign column
opt.signcolumn = "yes" -- always show, 1 column (adjust to "yes:2" if needed)

-- File navigation
opt.isfname:append("@-@") -- allows gf to handle @ in filenames

-- Disable unused providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
-- vim.g.loaded_python3_provider = 0  -- keep enabled: pyright uses it
