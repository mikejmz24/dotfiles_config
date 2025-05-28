-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Custom SQL formatter with sqlfluff
-- keymap.set("n", "<leader>sf", ":SqlFluffFormat<CR>", { silent = true })

-- Window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })
keymap.set("n", "<C-l>", "<C-W><", { desc = "Adjust split window size to the left" })
keymap.set("n", "<C-h>", "<C-W>>", { desc = "Adjust split window to the right" })
keymap.set("n", "<C-k>", "<C-W>+", { desc = "Adjust split window size up" })
keymap.set("n", "<C-j>", "<C-W>-", { desc = "Adjust split window size down" })

-- Global diagnostic keymaps (work regardless of LSP attachment)
keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic error messages" })
keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic quickfix list" })

-- Alternative diagnostic navigation (in case the LSP ones don't work)
keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end, { desc = "Go to previous diagnostic" })
keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end, { desc = "Go to next diagnostic" })
