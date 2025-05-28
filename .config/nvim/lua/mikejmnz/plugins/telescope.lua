return {
	"nvim-telescope/telescope.nvim",
	branch = "master",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		telescope.setup({
			defaults = {
				path_display = { "truncate" },
				file_ignore_patterns = {
					"node_modules",
					".git/",
					"%.lock",
					"__pycache__/",
					"%.pyc",
					"%.pyo",
					"%.pyd",
					"%.so",
					"%.dll",
				},
				-- Configure sorting and filtering
				sorting_strategy = "descending",
				layout_config = {
					prompt_position = "bottom",
				},
				-- Reduce duplicates by being more specific about what to search
				hidden = false,
				no_ignore = false,
				follow = false,
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
			},
			pickers = {
				find_files = {
					-- Prevent duplicate file entries
					find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
					-- Alternative for systems without ripgrep:
					-- find_command = { "find", ".", "-type", "f", "-not", "-path", "*/\\.git/*" },
				},
				live_grep = {
					additional_args = function()
						return { "--hidden", "--glob", "!**/.git/*" }
					end,
				},
			},
		})
		telescope.load_extension("fzf")
		local keymap = vim.keymap
		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
	end,
}
