return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"windwp/nvim-ts-autotag",
		},
		config = function()
			local treesitter = require("nvim-treesitter.configs")

			treesitter.setup({
				highlight = {
					enable = true,
					disable = { "markdown", "markdown_inline" },
				},
				indent = { enable = true },
				modules = {},
				sync_install = false,
				ignore_install = { "markdown", "markdown_inline" },
				auto_install = false,
				ensure_installed = {
					"html",
					"css",
					"json",
					"bash",
					"lua",
					"vim",
					"dockerfile",
					"gitignore",
					"python",
					"go",
					"templ",
					"make",
					"awk",
					"sql",
					"query",
					"yaml",
					"toml",
					"regex",
					"jq",
				},

				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<CR>",
						node_incremental = "<CR>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},
			})

			require("nvim-ts-autotag").setup()
		end,
	},
}
