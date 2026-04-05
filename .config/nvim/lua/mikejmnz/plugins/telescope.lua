return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")
		local keymap = vim.keymap

		telescope.setup({
			defaults = {
				path_display = { "truncate" },
				sorting_strategy = "descending",
				-- file_ignore_patterns removed: rg globs in find_files are more efficient
				layout_config = {
					prompt_position = "bottom",
					horizontal = { preview_width = 0.45 },
					vertical = { mirror = false },
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
				diagnostics = {
					initial_mode = "normal",
				},
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

		telescope.load_extension("fzf")

		-- File operations
		keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Find string under cursor in cwd" })

		-- Buffer operations
		keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Show open buffers" })

		-- LSP operations
		keymap.set("n", "<leader>ft", builtin.lsp_document_symbols, { desc = "Show document symbols" })
		keymap.set("n", "<leader>fT", builtin.lsp_workspace_symbols, { desc = "Show workspace symbols" })

		-- Diagnostic operations (simplified: duplicate LSP issue is fixed at source)
		keymap.set("n", "<leader>fd", function()
			builtin.diagnostics({ bufnr = 0 })
		end, { desc = "Show buffer diagnostics" })

		keymap.set("n", "<leader>fD", builtin.diagnostics, { desc = "Show workspace diagnostics" })

		-- Git operations
		keymap.set("n", "<leader>fg", function()
			local ok = pcall(builtin.git_files)
			if not ok then
				vim.notify("Not a git repo, showing all files", vim.log.levels.WARN)
				builtin.find_files()
			end
		end, { desc = "Find git files (fallback to all files)" })

		keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Show help tags" })
	end,
}
