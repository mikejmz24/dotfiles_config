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
				-- Enhanced diagnostics picker with FULL SIZE layout (same as other pickers)
				diagnostics = {
					-- Remove ivy theme to match other pickers
					initial_mode = "normal",
					-- Use same layout as other telescope pickers
				},
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
		-- ENHANCED DIAGNOSTIC DEDUPLICATION SYSTEM
		-- =================================================================

		-- Function to normalize diagnostic message (remove extra whitespace, etc.)
		local function normalize_message(message)
			return message:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
		end

		-- Clean diagnostic deduplication (debug removed)
		local function deduplicate_diagnostics(diagnostics)
			if #diagnostics == 0 then
				return diagnostics
			end

			local unique = {}
			local seen_keys = {}
			local removed_count = 0

			for _, diagnostic in ipairs(diagnostics) do
				-- Create key with cleaned message
				local lnum = diagnostic.lnum or 0
				local col = diagnostic.col or 0
				local message = (diagnostic.message or ""):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
				local source = diagnostic.source or ""
				local severity = diagnostic.severity or ""
				local code = diagnostic.code or ""

				local key = string.format("%d:%d:%s:%s:%s:%s", lnum, col, message, source, severity, code)

				if seen_keys[key] then
					removed_count = removed_count + 1
				else
					seen_keys[key] = true
					table.insert(unique, diagnostic)
				end
			end

			if removed_count > 0 then
				print(
					string.format(
						"✨ Removed %d duplicate diagnostics (%d → %d)",
						removed_count,
						#diagnostics,
						#unique
					)
				)
			end

			return unique
		end

		-- Clean diagnostics function that permanently removes duplicates
		local function show_clean_diagnostics(opts)
			opts = opts or {}
			local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()

			-- Get and deduplicate diagnostics
			local all_diagnostics = vim.diagnostic.get(bufnr)
			local unique_diagnostics = deduplicate_diagnostics(all_diagnostics)

			if #unique_diagnostics == 0 then
				print("No diagnostics found")
				return
			end

			-- If we removed duplicates, make the cleaning permanent
			if #unique_diagnostics < #all_diagnostics then
				-- Get all namespaces and clear them
				local all_namespaces = {}
				for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
					local ns = vim.lsp.diagnostic.get_namespace(client.id)
					table.insert(all_namespaces, ns)
				end

				-- Clear all diagnostics
				vim.diagnostic.reset(nil, bufnr)
				for _, ns in ipairs(all_namespaces) do
					vim.diagnostic.reset(ns, bufnr)
				end

				-- Set the clean diagnostics permanently
				if #all_namespaces > 0 then
					vim.diagnostic.set(all_namespaces[1], bufnr, unique_diagnostics)
					print(string.format("🧹 Permanently cleaned buffer diagnostics"))
				end
			end

			-- Show telescope (now with clean diagnostics)
			builtin.diagnostics(vim.tbl_extend("force", {
				bufnr = bufnr,
				severity_limit = vim.diagnostic.severity.HINT,
			}, opts))
		end

		-- =================================================================
		-- DIAGNOSTIC KEYMAPS
		-- =================================================================

		-- Clean buffer diagnostics
		keymap.set("n", "<leader>fd", function()
			show_clean_diagnostics({ bufnr = 0 })
		end, { desc = "Show buffer diagnostics (clean)" })

		-- Clean workspace diagnostics
		keymap.set("n", "<leader>fD", function()
			show_clean_diagnostics({})
		end, { desc = "Show workspace diagnostics (clean)" })

		-- =================================================================
		-- UTILITY DIAGNOSTIC COMMANDS
		-- =================================================================

		-- -- Copy current line diagnostic to clipboard
		-- keymap.set("n", "<leader>dy", function()
		-- 	local line = vim.fn.line(".") - 1
		-- 	local diagnostics = vim.diagnostic.get(0, { lnum = line })
		-- 	if #diagnostics > 0 then
		-- 		local text = normalize_message(diagnostics[1].message)
		-- 		vim.fn.setreg("+", text)
		-- 		print("Diagnostic copied: " .. text:sub(1, 50) .. (text:len() > 50 and "..." or ""))
		-- 	else
		-- 		print("No diagnostic on current line")
		-- 	end
		-- end, { desc = "Copy line diagnostic to clipboard" })
	end,
}
