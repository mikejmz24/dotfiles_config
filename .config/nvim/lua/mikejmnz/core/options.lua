local opt = vim.opt

-- line numbers
opt.number = true

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- line wrapping
opt.wrap = false

-- search settings
opt.ignorecase = true
opt.smartcase = true

-- cursor line
opt.cursorline = true

-- appearance
opt.termguicolors = true

-- backspace
opt.backspace = "indent,eol,start"

-- clipboard
opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true

-- Additional performance and stability options
opt.updatetime = 250 -- Faster completion and diagnostics
opt.timeoutlen = 300 -- Faster which-key popup
opt.redrawtime = 10000 -- Allow more time for syntax highlighting
opt.synmaxcol = 240 -- Limit syntax highlighting for long lines
opt.lazyredraw = false -- Don't lazy redraw
opt.ttyfast = true -- Fast terminal connection

-- Better file handling
opt.autoread = true -- Auto reload files changed outside nvim
opt.autowrite = true -- Auto write files when switching buffers
opt.confirm = true -- Confirm before closing unsaved files

-- Better search and replace
opt.inccommand = "split" -- Show incremental search results

-- Better completion
opt.completeopt = "menu,menuone,noselect,preview"
opt.pumheight = 10 -- Limit completion menu height

-- Diagnostics stability
opt.signcolumn = "yes:2" -- Always show sign column with space for 2 signs

-- Disable unused providers to eliminate warnings
vim.g.loaded_node_provider = 0 -- Disable Node.js provider
vim.g.loaded_perl_provider = 0 -- Disable Perl provider
-- vim.g.loaded_python3_provider = 0   -- Disable Python provider
vim.g.loaded_ruby_provider = 0 -- Disable Ruby provider
