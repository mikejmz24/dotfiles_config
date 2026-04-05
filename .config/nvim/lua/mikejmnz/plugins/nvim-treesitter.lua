return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"windwp/nvim-ts-autotag",
		},
		config = function()
			local treesitter = require("nvim-treesitter.configs")

			treesitter.setup({
				highlight = { enable = true },
				indent = { enable = true },

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
						init_selection = "<CR>", -- changed: was <C-space>, conflicts with cmp
						node_incremental = "<CR>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},

				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							["aa"] = "@parameter.outer",
							["ia"] = "@parameter.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							["]f"] = "@function.outer",
							["]c"] = "@class.outer",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
							["[c"] = "@class.outer",
						},
					},
				},
			})

			-- autotag requires its own setup call since v0.7.0
			require("nvim-ts-autotag").setup()
		end,
	},
}
