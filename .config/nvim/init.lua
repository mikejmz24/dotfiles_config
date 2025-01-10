require("mikejmnz.core")
require("mikejmnz.lazy")
-- init.lua or in a separate file sourced by your init.lua
vim.api.nvim_command("autocmd BufRead,BufNewFile *.templ set filetype=templ")
