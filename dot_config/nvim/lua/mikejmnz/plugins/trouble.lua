return {
	"folke/trouble.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Toggle trouble list" },
		{
			"<leader>xw",
			"<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
			desc = "Toggle trouble document diagnostics",
		},
		{
			"<leader>xd",
			"<cmd>Trouble diagnostics toggle<CR>",
			desc = "Toggle trouble workspace diagnostics",
		},
		{
			"<leader>xq",
			"<cmd>Trouble qflist toggle<CR>",
			desc = "Toggle trouble quickfix list",
		},
		{
			"<leader>xl",
			"<cmd>Trouble loclist toggle<CR>",
			desc = "Toggle trouble location list",
		},
		{
			"<leader>xs",
			"<cmd>Trouble lsp toggle focus=false win.position=right<CR>",
			desc = "Toggle LSP definitions/references",
		},
		{
			"<leader>xt",
			"<cmd>Trouble todo toggle<CR>",
			desc = "Toggle todos in trouble",
		},
	},
}
