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

		-- LSP operations
		keymap.set("n", "<leader>ft", builtin.lsp_document_symbols, { desc = "Show document symbols" })
		keymap.set("n", "<leader>fT", builtin.lsp_workspace_symbols, { desc = "Show workspace symbols" })

		-- Git operations
		keymap.set("n", "<leader>fg", builtin.git_files, { desc = "Find git files" })
		keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Show help tags" })

		-- =================================================================
		-- ROBUST DUPLICATE PREVENTION
		-- =================================================================

		-- Function to deduplicate diagnostics by creating a custom namespace
		local function get_deduped_diagnostics(bufnr)
			bufnr = bufnr or vim.api.nvim_get_current_buf()

			-- Get all diagnostics from all namespaces
			local all_diagnostics = vim.diagnostic.get(bufnr)

			-- Filter out duplicates
			local unique_diagnostics = {}
			local seen = {}

			for _, diagnostic in ipairs(all_diagnostics) do
				-- Create a unique key for each diagnostic
				local key = string.format(
					"%d:%d:%s:%d",
					diagnostic.lnum,
					diagnostic.col,
					diagnostic.message:gsub("%s+", " "), -- normalize whitespace
					diagnostic.severity
				)

				if not seen[key] then
					seen[key] = true
					table.insert(unique_diagnostics, diagnostic)
				end
			end

			return unique_diagnostics
		end

		-- Create custom namespace for clean diagnostics
		local clean_ns = vim.api.nvim_create_namespace("telescope_clean_diagnostics")

		-- Function to set clean diagnostics temporarily
		local function set_clean_diagnostics(bufnr)
			bufnr = bufnr or vim.api.nvim_get_current_buf()

			-- Get unique diagnostics
			local unique_diagnostics = get_deduped_diagnostics(bufnr)

			-- Clear our clean namespace
			vim.diagnostic.reset(clean_ns, bufnr)

			-- Set unique diagnostics in our namespace
			vim.diagnostic.set(clean_ns, bufnr, unique_diagnostics)

			return unique_diagnostics
		end

		-- =================================================================
		-- MAIN DIAGNOSTIC KEYMAPS - ROBUST VERSION
		-- =================================================================

		-- Buffer diagnostics - actually removes duplicates
		keymap.set("n", "<leader>fd", function()
			local buf = vim.api.nvim_get_current_buf()

			-- Set clean diagnostics and get count
			local unique_diagnostics = set_clean_diagnostics(buf)

			-- Override vim.diagnostic.get ONLY for telescope call
			local original_get = vim.diagnostic.get
			local telescope_active = true

			vim.diagnostic.get = function(query_buf, opts)
				-- Only override when telescope is active and querying our buffer
				if telescope_active and (query_buf == buf or query_buf == nil) then
					return unique_diagnostics
				end
				return original_get(query_buf, opts)
			end

			-- Show diagnostics in telescope
			builtin.diagnostics({
				bufnr = buf,
				severity_limit = vim.diagnostic.severity.HINT,
			})

			-- Restore original function after telescope finishes
			vim.defer_fn(function()
				telescope_active = false
				vim.diagnostic.get = original_get
				-- Clean up our temporary namespace
				vim.diagnostic.reset(clean_ns, buf)
			end, 2000)

			print(string.format("Showing %d unique diagnostics (duplicates filtered)", #unique_diagnostics))
		end, { desc = "Show buffer diagnostics (duplicates removed)" })

		-- Manual duplicate cleanup command
		keymap.set("n", "<leader>dd", function()
			local buf = vim.api.nvim_get_current_buf()
			local original_count = #vim.diagnostic.get(buf)

			-- Get unique diagnostics
			local unique_diagnostics = get_deduped_diagnostics(buf)

			-- Clear ALL diagnostics from buffer
			vim.diagnostic.reset(nil, buf)

			-- Wait a moment, then set only unique ones
			vim.defer_fn(function()
				if #unique_diagnostics > 0 then
					-- Set them back using the first available namespace
					local clients = vim.lsp.get_clients({ bufnr = buf })
					if #clients > 0 then
						local ns = vim.lsp.diagnostic.get_namespace(clients[1].id)
						vim.diagnostic.set(ns, buf, unique_diagnostics)
					end
				end

				print(string.format("Removed duplicates: %d → %d diagnostics", original_count, #unique_diagnostics))
			end, 100)
		end, { desc = "Remove duplicate diagnostics" })

		-- =================================================================
		-- UTILITY COMMANDS (SIMPLIFIED)
		-- =================================================================

		-- Copy current line diagnostic to clipboard
		keymap.set("n", "<leader>dy", function()
			local line = vim.fn.line(".") - 1
			local diagnostics = vim.diagnostic.get(0, { lnum = line })
			if #diagnostics > 0 then
				local text = diagnostics[1].message
				vim.fn.setreg("+", text)
				print("Diagnostic copied: " .. text:sub(1, 50) .. (text:len() > 50 and "..." or ""))
			else
				print("No diagnostic on current line")
			end
		end, { desc = "Copy line diagnostic to clipboard" })

		-- Clear all diagnostics (emergency)
		keymap.set("n", "<leader>dC", function()
			vim.diagnostic.reset()
			print("All diagnostics cleared")
		end, { desc = "Clear all diagnostics" })
	end,
}
