return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
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
					"node_modules/",
					".git/",
					"%.lock$",
					"__pycache__/",
					"%.pyc$",
					"%.pyo$",
					"%.pyd$",
					"%.so$",
					"%.dll$",
					"%.class$",
					"%.jar$",
					"target/",
					"build/",
					"dist/",
				},
				sorting_strategy = "descending",
				layout_config = {
					prompt_position = "bottom",
					horizontal = {
						preview_width = 0.45,
						-- results_width = 0.5,
					},
					vertical = {
						mirror = false,
					},
					width = 0.87,
					height = 0.80,
				},
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
						["<C-u>"] = false,
						["<C-d>"] = actions.delete_buffer + actions.move_to_top,
					},
					n = {
						["q"] = actions.close,
						["dd"] = actions.delete_buffer + actions.move_to_top,
					},
				},
			},
			pickers = {
				find_files = {
					find_command = {
						"rg",
						"--files",
						"--hidden",
						"--no-follow",
						"--glob",
						"!**/.git/*",
						"--glob",
						"!**/node_modules/*",
						"--glob",
						"!**/__pycache__/*",
					},
				},
				live_grep = {
					additional_args = function()
						return {
							"--hidden",
							"--no-follow",
							"--glob",
							"!**/.git/*",
							"--glob",
							"!**/node_modules/*",
							"--glob",
							"!**/__pycache__/*",
						}
					end,
				},
				grep_string = {
					additional_args = function()
						return {
							"--hidden",
							"--no-follow",
							"--glob",
							"!**/.git/*",
							"--glob",
							"!**/node_modules/*",
						}
					end,
				},
				buffers = {
					show_all_buffers = true,
					sort_mru = true,
					ignore_current_buffer = false,
				},
				-- Minimal diagnostic configuration to avoid deprecation issues
				diagnostics = {},
				lsp_references = {},
				lsp_definitions = {},
				lsp_implementations = {},
				lsp_type_definitions = {},
			},
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
			},
		})

		-- Load extensions
		telescope.load_extension("fzf")

		-- Keymaps using require to avoid issues
		local builtin = require("telescope.builtin")
		local keymap = vim.keymap

		-- File operations
		keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Find string under cursor in cwd" })

		-- Buffer operations
		keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Show open buffers" })

		-- Diagnostic operations (simplified to avoid deprecation warnings)
		keymap.set("n", "<leader>fd", function()
			builtin.diagnostics({ bufnr = 0 })
		end, { desc = "Show buffer diagnostics" })

		keymap.set("n", "<leader>fD", builtin.diagnostics, { desc = "Show all workspace diagnostics" })

		-- LSP operations
		keymap.set("n", "<leader>ft", builtin.lsp_document_symbols, { desc = "Show document symbols" })
		keymap.set("n", "<leader>fT", builtin.lsp_workspace_symbols, { desc = "Show workspace symbols" })

		-- Git operations
		keymap.set("n", "<leader>fg", builtin.git_files, { desc = "Find git files" })
		keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Show help tags" })
	end,
}
