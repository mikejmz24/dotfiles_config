-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })
keymap.set("n", "<C-l>", "<C-W><", { desc = "Adjust split window size to the left" })
keymap.set("n", "<C-h>", "<C-W>>", { desc = "Adjust split window to the right" })
keymap.set("n", "<C-k>", "<C-W>+", { desc = "Adjust split window size up" })
keymap.set("n", "<C-j>", "<C-W>-", { desc = "Adjust split window size down" })

-- Better buffer navigation
keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

-- Better diagnostic navigation with error handling
keymap.set("n", "<leader>e", function()
	local opts = {
		focusable = false,
		close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
		border = "rounded",
		source = "always",
		prefix = " ",
		scope = "cursor",
	}
	vim.diagnostic.open_float(nil, opts)
end, { desc = "Show diagnostic error messages" })

keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic quickfix list" })

-- Improved diagnostic navigation with try-catch
keymap.set("n", "[d", function()
	local ok, err = pcall(vim.diagnostic.jump, { count = -1 })
	if not ok then
		print("No more diagnostics: " .. err)
	end
end, { desc = "Go to previous diagnostic" })

keymap.set("n", "]d", function()
	local ok, err = pcall(vim.diagnostic.jump, { count = 1 })
	if not ok then
		print("No more diagnostics: " .. err)
	end
end, { desc = "Go to next diagnostic" })

-- -- Quick diagnostic refresh
-- keymap.set("n", "<leader>dR", function()
-- 	vim.diagnostic.reset()
-- 	vim.defer_fn(function()
-- 		vim.diagnostic.enable()
-- 		print("Diagnostics refreshed")
-- 	end, 100)
-- end, { desc = "Refresh diagnostics" })

-- Better LSP restart
keymap.set("n", "<leader>lR", function()
	vim.cmd("LspRestart")
	vim.defer_fn(function()
		print("LSP restarted")
	end, 1000)
end, { desc = "Restart LSP" })

-- Quick save and quit
keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap.set("n", "<leader>W", ":wa<CR>", { desc = "Save all files" })
keymap.set("n", "<leader>Q", ":qa<CR>", { desc = "Quit all" })

-- Better paste in visual mode (keeps register)
keymap.set("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Move lines up/down in visual mode
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better indenting in visual mode
keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })
