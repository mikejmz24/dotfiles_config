require("mikejmnz.core")
require("mikejmnz.lazy")
-- init.lua or in a separate file sourced by your init.lua
vim.api.nvim_command("autocmd BufRead,BufNewFile *.templ set filetype=templ")
-- vim.g.sqlfluff_path = "/opt/homebrew/bin/sqlfluff"

-- NOTE: Delete the lines below
-- Add this to your init.lua or a separate debug file
vim.api.nvim_create_user_command("DebugSqlSetup", function()
	-- Check SQLFluff path
	print("SQLFluff Path: " .. (vim.fn.exepath("sqlfluff") or "Not found"))

	-- Check current file type
	print("Current File Type: " .. vim.bo.filetype)

	-- Manually trigger file type detection
	vim.cmd("filetype detect")
	print("After detection: " .. vim.bo.filetype)

	-- List all runtime paths for SQL detection
	print("SQL Runtime Paths:")
	for _, path in ipairs(vim.api.nvim_get_runtime_file("ftdetect/sql.vim", true)) do
		print(path)
	end
end, {})

vim.api.nvim_create_user_command("SqlFluffTest", function()
	local file = vim.fn.expand("%:p")
	local cmd = string.format("sqlfluff format --dialect mysql %s", file)

	print("Running command: " .. cmd)
	local result = vim.fn.system(cmd)
	print(result)
end, {})

vim.api.nvim_create_user_command("ConformDebug", function()
	local sqlfluff_path = vim.fn.stdpath("data") .. "/mason/packages/sqlfluff/venv/bin/sqlfluff" -- or however you get the path
	local file_path = vim.fn.expand("%:p") -- Current file path
	local mason_bin_dir = vim.fn.stdpath("data") .. "/mason/bin"
	local sqlfluff_bin_dir = vim.fn.stdpath("data") .. "/mason/packages/sqlfluff/venv/bin"

	print("sqlfluff path: " .. sqlfluff_path)
	print("file path: " .. file_path)
	print("mason path: " .. mason_bin_dir)
	print("sqlfluff bin path: " .. sqlfluff_bin_dir)

	local cmd = { sqlfluff_path, "fix", "--dialect", "mysql", file_path }
	local output = vim.fn.system(cmd)
	print("sqlfluff output: " .. output)
end, {})
--
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.loop.fs_stat(lazypath) then
-- 	vim.fn.system({
-- 		"git",
-- 		"clone",
-- 		"--filter=blob:none",
-- 		"https://github.com/folke/lazy.nvim.git",
-- 		"--branch=stable", -- latest stable release
-- 		lazypath,
-- 	})
-- end
-- vim.opt.rtp:prepend(lazypath)
--
-- require("lazy").setup({ 
-- 'stevenart/conform.nvim',
-- opts = {
-- 	formatters = {
-- 		sqlfluff = {
-- 			command = "/Users/miguel.jimenez2/.local/share/nvim/mason/bin/sqlfluff",
-- 			args = { "fix", "--dialect", "mysql", "-" },
-- 			stdin = true,
-- 			prepend_args = true,
-- 			cwd = function(params)
-- 				return vim.fn.getcwd()
-- 			end,
-- 		},
-- 	},
-- 	formatters_by_ft = {
-- 		sql = { "sqlfluff" },
-- 		mysql = { "sqlfluff" },
-- 		postgresql = { "sqlfluff" },
-- 	},
-- },
-- })
