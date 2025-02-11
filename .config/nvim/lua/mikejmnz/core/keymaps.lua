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
