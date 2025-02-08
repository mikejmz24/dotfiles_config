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

vim.api.nvim_create_user_command("SqlFluffFormat", function()
	-- Store cursor position
	local cursor_pos = vim.api.nvim_win_get_cursor(0)

	-- Get current buffer content
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local content = table.concat(lines, "\n")

	-- Create temporary file with error handling
	local tmp_file = vim.fn.tempname()
	local f = io.open(tmp_file, "w")

	if not f then
		vim.notify("Failed to create temporary file", vim.log.levels.ERROR)
		return
	end

	local success, write_err = pcall(function()
		f:write(content)
	end)

	if not success then
		vim.notify("Failed to write to temporary file: " .. tostring(write_err), vim.log.levels.ERROR)
		f:close()
		os.remove(tmp_file)
		return
	end

	local close_success, close_err = pcall(function()
		f:close()
	end)

	if not close_success then
		vim.notify("Failed to close temporary file: " .. tostring(close_err), vim.log.levels.ERROR)
		os.remove(tmp_file)
		return
	end

	-- Run sqlfluff on temporary file
	local cmd = string.format("sqlfluff format --dialect mysql %s", tmp_file)
	vim.fn.system(cmd)

	-- Read the formatted content back from the file
	local formatted_file = io.open(tmp_file, "r")
	if not formatted_file then
		vim.notify("Failed to read formatted file", vim.log.levels.ERROR)
		os.remove(tmp_file)
		return
	end

	local formatted_content = formatted_file:read("*a")
	formatted_file:close()

	-- Remove temporary file
	os.remove(tmp_file)

	-- If we got content successfully
	if formatted_content then
		-- Convert formatted string back to lines
		local new_lines = {}
		for line in formatted_content:gmatch("[^\r\n]+") do
			table.insert(new_lines, line)
		end

		-- Replace buffer content
		vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)

		-- Restore cursor position with bounds checking
		local new_line_count = #new_lines
		if new_line_count > 0 then
			cursor_pos[1] = math.min(cursor_pos[1], new_line_count)
			local line_length = string.len(new_lines[cursor_pos[1]])
			cursor_pos[2] = math.min(cursor_pos[2], line_length)
			vim.api.nvim_win_set_cursor(0, cursor_pos)
		end
	else
		vim.notify("SQLFluff formatting failed: no content returned", vim.log.levels.ERROR)
	end
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
