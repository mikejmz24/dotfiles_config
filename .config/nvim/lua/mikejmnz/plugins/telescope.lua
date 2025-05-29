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

		-- Manual duplicate cleanup with safer logic
		keymap.set("n", "<leader>dd", function()
			local bufnr = vim.api.nvim_get_current_buf()
			local original_diagnostics = vim.diagnostic.get(bufnr)
			local original_count = #original_diagnostics

			if original_count == 0 then
				print("No diagnostics to clean")
				return
			end

			-- Check for exact duplicates only
			local unique_diagnostics = {}
			local seen_exact = {}
			local duplicate_count = 0

			for _, diagnostic in ipairs(original_diagnostics) do
				local key = string.format(
					"%d:%d:%d:%s",
					diagnostic.lnum or 0,
					diagnostic.col or 0,
					diagnostic.severity or 1,
					diagnostic.message or ""
				)

				if seen_exact[key] then
					duplicate_count = duplicate_count + 1
				else
					seen_exact[key] = true
					table.insert(unique_diagnostics, diagnostic)
				end
			end

			if duplicate_count == 0 then
				print("No exact duplicates found")
				return
			end

			print(
				string.format(
					"Found %d exact duplicates, would reduce %d → %d diagnostics",
					duplicate_count,
					original_count,
					#unique_diagnostics
				)
			)

			-- Ask for confirmation
			local confirm =
				vim.fn.confirm(string.format("Remove %d duplicate diagnostics?", duplicate_count), "&Yes\n&No", 2)

			if confirm == 1 then
				-- Clear all diagnostics
				vim.diagnostic.reset(nil, bufnr)

				-- Set unique diagnostics back
				vim.defer_fn(function()
					if vim.api.nvim_buf_is_valid(bufnr) and #unique_diagnostics > 0 then
						-- Find the appropriate namespace to use
						local clients = vim.lsp.get_clients({ bufnr = bufnr })
						if #clients > 0 then
							for _, client in ipairs(clients) do
								if client.server_capabilities.diagnosticProvider then
									local ns = vim.lsp.diagnostic.get_namespace(client.id)
									vim.diagnostic.set(ns, bufnr, unique_diagnostics)
									print(
										string.format(
											"Removed %d exact duplicates (%d → %d)",
											duplicate_count,
											original_count,
											#unique_diagnostics
										)
									)
									break
								end
							end
						else
							print("Warning: Could not find LSP client to restore diagnostics")
						end
					end
				end, 100)
			else
				print("Cancelled")
			end
		end, { desc = "Remove duplicate diagnostics (with confirmation)" })

		-- =================================================================
		-- UTILITY DIAGNOSTIC COMMANDS
		-- =================================================================

		-- Copy current line diagnostic to clipboard
		keymap.set("n", "<leader>dy", function()
			local line = vim.fn.line(".") - 1
			local diagnostics = vim.diagnostic.get(0, { lnum = line })
			if #diagnostics > 0 then
				local text = normalize_message(diagnostics[1].message)
				vim.fn.setreg("+", text)
				print("Diagnostic copied: " .. text:sub(1, 50) .. (text:len() > 50 and "..." or ""))
			else
				print("No diagnostic on current line")
			end
		end, { desc = "Copy line diagnostic to clipboard" })

		-- DEBUG: Test deduplication logic with current buffer data
		keymap.set("n", "<leader>dT", function()
			local bufnr = vim.api.nvim_get_current_buf()
			local all_diagnostics = vim.diagnostic.get(bufnr)

			print("=== TESTING DEDUPLICATION LOGIC ===")
			print(string.format("Input: %d diagnostics", #all_diagnostics))

			-- Test our deduplication function
			local unique = deduplicate_diagnostics(all_diagnostics)

			print(string.format("Output: %d diagnostics", #unique))
			print("=== END TEST ===")
		end, { desc = "DEBUG: Test deduplication logic" })

		-- DEBUG: Diagnostic analysis function
		keymap.set("n", "<leader>dD", function()
			local bufnr = vim.api.nvim_get_current_buf()
			local all_diagnostics = vim.diagnostic.get(bufnr)

			print("=== DIAGNOSTIC ANALYSIS ===")
			print(string.format("Total diagnostics found: %d", #all_diagnostics))
			print("")

			-- Group by message to find duplicates
			local message_groups = {}
			local location_groups = {}

			for i, diagnostic in ipairs(all_diagnostics) do
				local msg = diagnostic.message or "NO_MESSAGE"
				local location = string.format("%d:%d", diagnostic.lnum or 0, diagnostic.col or 0)
				local source = diagnostic.source or "NO_SOURCE"
				local severity = diagnostic.severity or "NO_SEVERITY"
				local code = diagnostic.code or "NO_CODE"

				-- Group by message
				message_groups[msg] = message_groups[msg] or {}
				table.insert(message_groups[msg], {
					index = i,
					location = location,
					source = source,
					severity = severity,
					code = code,
				})

				-- Group by location
				location_groups[location] = location_groups[location] or {}
				table.insert(location_groups[location], {
					index = i,
					message = msg:sub(1, 50) .. (msg:len() > 50 and "..." or ""),
					source = source,
					severity = severity,
				})
			end

			-- Show duplicates by message
			print("=== DUPLICATES BY MESSAGE ===")
			local found_message_duplicates = false
			for msg, group in pairs(message_groups) do
				if #group > 1 then
					found_message_duplicates = true
					print(string.format("Message: %s", msg:sub(1, 80) .. (msg:len() > 80 and "..." or "")))
					print(string.format("  Count: %d duplicates", #group))
					for _, info in ipairs(group) do
						print(
							string.format(
								"    [%d] %s | Source: %s | Severity: %s | Code: %s",
								info.index,
								info.location,
								info.source,
								info.severity,
								info.code
							)
						)
					end
					print("")
				end
			end
			if not found_message_duplicates then
				print("No duplicate messages found")
			end

			print("=== DUPLICATES BY LOCATION ===")
			local found_location_duplicates = false
			for location, group in pairs(location_groups) do
				if #group > 1 then
					found_location_duplicates = true
					print(string.format("Location: %s", location))
					print(string.format("  Count: %d diagnostics", #group))
					for _, info in ipairs(group) do
						print(
							string.format(
								"    [%d] %s | Source: %s | Severity: %s",
								info.index,
								info.message,
								info.source,
								info.severity
							)
						)
					end
					print("")
				end
			end
			if not found_location_duplicates then
				print("No duplicate locations found")
			end

			-- Show first few diagnostics in detail
			print("=== FIRST 3 DIAGNOSTICS (RAW DATA) ===")
			for i = 1, math.min(3, #all_diagnostics) do
				local d = all_diagnostics[i]
				print(string.format("Diagnostic %d:", i))
				print(string.format("  lnum: %s", tostring(d.lnum)))
				print(string.format("  col: %s", tostring(d.col)))
				print(string.format("  message: %s", tostring(d.message)))
				print(string.format("  source: %s", tostring(d.source)))
				print(string.format("  severity: %s", tostring(d.severity)))
				print(string.format("  code: %s", tostring(d.code)))
				print(string.format("  namespace: %s", tostring(d.namespace)))
				print("")
			end

			print("=== END ANALYSIS ===")
		end, { desc = "DEBUG: Analyze diagnostics for duplicates" })

		-- Clear all diagnostics (emergency)
		keymap.set("n", "<leader>dC", function()
			vim.diagnostic.reset()
			print("All diagnostics cleared")
		end, { desc = "Clear all diagnostics" })

		-- Toggle diagnostics
		keymap.set("n", "<leader>dt", function()
			if vim.diagnostic.is_enabled() then
				vim.diagnostic.enable(false)
				print("Diagnostics disabled")
			else
				vim.diagnostic.enable(true)
				print("Diagnostics enabled")
			end
		end, { desc = "Toggle diagnostics" })
	end,
}
