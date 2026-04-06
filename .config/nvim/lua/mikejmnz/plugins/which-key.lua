return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	-- init block removed: timeout is a no-op, timeoutlen belongs in options.lua
	opts = {
		spec = {
			-- Existing groups
			{ "<leader>f", group = "find/files (telescope)" },
			{ "<leader>s", group = "splits" },
			{ "<leader>b", group = "buffer" },
			{ "<leader>l", group = "lsp" },
			{ "<leader>d", group = "diagnostics" },
			{ "<leader>n", group = "swap next" },
			{ "<leader>p", group = "swap previous" },
			{ "<leader>m", group = "format" },
			{ "<leader>r", group = "rename/restart" },
			{ "<leader>y", group = "yank" },
			{ "<leader>x", group = "trouble/diagnostics" }, -- added from trouble.lua review
			{ "<leader>t", group = "toggle" },
			{ "<leader>c", group = "code actions" }, -- added: <leader>ca from lspconfig
			{ "g", group = "goto" },
			{ "]", group = "next" },
			{ "[", group = "previous" },
		},
	},
}
