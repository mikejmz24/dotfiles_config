return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		-- local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local keymap = vim.keymap

		local on_attach = function(client, bufnr)
			local opts = { noremap = true, silent = true, buffer = bufnr }

			-- LSP keybinds
			keymap.set(
				"n",
				"gR",
				"<cmd>Telescope lsp_references<CR>",
				vim.tbl_extend("force", opts, { desc = "Show LSP references" })
			)
			keymap.set(
				"n",
				"gD",
				vim.lsp.buf.declaration,
				vim.tbl_extend("force", opts, { desc = "Go to declaration" })
			)
			keymap.set(
				"n",
				"gd",
				"<cmd>Telescope lsp_definitions<CR>",
				vim.tbl_extend("force", opts, { desc = "Show LSP definitions" })
			)
			keymap.set(
				"n",
				"gi",
				"<cmd>Telescope lsp_implementations<CR>",
				vim.tbl_extend("force", opts, { desc = "Show LSP implementations" })
			)
			keymap.set(
				"n",
				"gt",
				"<cmd>Telescope lsp_type_definitions<CR>",
				vim.tbl_extend("force", opts, { desc = "Show LSP type definitions" })
			)
			keymap.set(
				{ "n", "v" },
				"<leader>ca",
				vim.lsp.buf.code_action,
				vim.tbl_extend("force", opts, { desc = "See available code actions" })
			)
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Smart rename" }))
			keymap.set(
				"n",
				"<leader>D",
				"<cmd>Telescope diagnostics bufnr=0<CR>",
				vim.tbl_extend("force", opts, { desc = "Show buffer diagnostics" })
			)
			keymap.set(
				"n",
				"<leader>d",
				vim.diagnostic.open_float,
				vim.tbl_extend("force", opts, { desc = "Show line diagnostics" })
			)

			keymap.set("n", "[d", function()
				vim.diagnostic.jump({ count = -1 })
			end, vim.tbl_extend("force", opts, { desc = "Go to previous diagnostic" }))

			keymap.set("n", "]d", function()
				vim.diagnostic.jump({ count = 1 })
			end, vim.tbl_extend("force", opts, { desc = "Go to next diagnostic" }))

			keymap.set(
				"n",
				"K",
				vim.lsp.buf.hover,
				vim.tbl_extend("force", opts, { desc = "Show documentation for what is under cursor" })
			)
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", vim.tbl_extend("force", opts, { desc = "Restart LSP" }))
		end

		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Configure diagnostics (this enables them globally)
		vim.diagnostic.config({
			virtual_text = {
				spacing = 4,
				source = "if_many",
				prefix = "●",
			},
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			float = {
				border = "rounded",
				source = true,
				header = "",
				prefix = "",
				focusable = true,
			},
		})

		-- Diagnostic signs - avoid reserved word 'type'
		local diagnostic_signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }

		for sign_name, icon in pairs(diagnostic_signs) do
			local hl = "DiagnosticSign" .. sign_name
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- Configure signs for newer Neovim versions
		if vim.fn.has("nvim-0.10") == 1 then
			vim.diagnostic.config({
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
						[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
						[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
						[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
					},
				},
			})
		end

		-- ===================================================================
		-- ELEGANT SOLUTION: Automatically prevent duplicate LSP clients
		-- ===================================================================

		-- Enhanced function to prevent duplicate LSP clients at attach time
		local function prevent_duplicate_lsp_clients()
			print("🔧 Enabling LSP duplicate prevention...")

			local active_clients_by_key = {}
			local seen_client_ids = {} -- Track which client IDs we've already processed

			-- Hook into LspAttach event to catch duplicates as they attach
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if not client then
						return
					end

					local client_key = string.format("%s:%s", client.name, client.config.root_dir or "none")

					-- If we've already seen this exact client ID, it's just attaching to another buffer
					-- This is normal behavior, not a duplicate
					if seen_client_ids[client.id] then
						return -- Silent - no need to log normal buffer attachments
					end

					-- Mark this client ID as seen
					seen_client_ids[client.id] = true

					-- Check if we already have a DIFFERENT client with this name + root combination
					if active_clients_by_key[client_key] then
						local existing_client_id = active_clients_by_key[client_key]
						local existing_client = vim.lsp.get_client_by_id(existing_client_id)

						if existing_client and existing_client_id ~= client.id then
							print(
								string.format(
									"🚫 STOPPING duplicate %s client (ID: %d) - keeping existing (ID: %d)",
									client.name,
									client.id,
									existing_client_id
								)
							)

							-- Stop the duplicate client immediately
							vim.lsp.stop_client(client.id, true)
							return
						end
					end

					-- This is the first/primary client for this key
					active_clients_by_key[client_key] = client.id
					print(string.format("✅ Registered %s client (ID: %d) as primary", client.name, client.id))
				end,
			})

			-- Clean up tracking when clients stop
			vim.api.nvim_create_autocmd("LspDetach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client then
						local client_key = string.format("%s:%s", client.name, client.config.root_dir or "none")
						if active_clients_by_key[client_key] == args.data.client_id then
							active_clients_by_key[client_key] = nil
							seen_client_ids[args.data.client_id] = nil
							print(
								string.format(
									"🧹 Cleaned up tracking for %s client (ID: %d)",
									client.name,
									args.data.client_id
								)
							)
						end
					end
				end,
			})
		end
		-- Enable automatic duplicate prevention and cleanup
		prevent_duplicate_lsp_clients()

		-- ===================================================================
		-- LSP SERVER CONFIGURATIONS
		-- ===================================================================

		local servers = {
			["htmx"] = { capabilities = capabilities, on_attach = on_attach },
			["pyright"] = {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							extraPaths = { "~/Documents/localDocuments/" },
							typeCheckingMode = "basic",
						},
					},
				},
			},
			["lua_ls"] = {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = {
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.stdpath("config") .. "/lua"] = true,
							},
							checkThirdParty = false,
						},
						runtime = {
							version = "LuaJIT",
							path = vim.split(package.path, ";"),
						},
						telemetry = { enable = false },
					},
				},
			},
			["jqls"] = { capabilities = capabilities, on_attach = on_attach },
			["gopls"] = { capabilities = capabilities, on_attach = on_attach },
			["templ"] = {
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { "templ", "lsp" },
				filetypes = { "html", "templ" },
			},
			["sqls"] = {
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { "sqls" },
				filetypes = { "sql", "mysql", "postgresql" },
				-- root_dir = function(fname)
				-- 	local util = require("lspconfig.util")
				-- 	return util.root_pattern(".git")(fname)
				-- 		or util.root_pattern("init.sql", "schema.sql")(fname)
				-- 		or vim.fn.getcwd()
				-- end,
				root_dir = function(fname)
					return vim.fs.root(fname, { ".git", "init.sql", "schema.sql" }) or vim.fn.getcwd()
				end,
				settings = {
					sqls = {
						format = false,
						defaultDriver = "mysql",
						connections = {},
					},
				},
			},
			["texlab"] = {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					texlab = {
						build = {
							executable = "latexmk",
							args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
							onSave = true,
						},
						chktex = {
							onOpenAndSave = true,
							onEdit = false,
						},
						diagnosticsDelay = 300,
					},
				},
			},
		}

		-- -- Setup all servers
		-- for server_name, config in pairs(servers) do
		-- 	if lspconfig[server_name] then
		-- 		lspconfig[server_name].setup(config)
		-- 	end
		-- end
		for server_name, config in pairs(servers) do
			vim.lsp.config(server_name, config)
			vim.lsp.enable(server_name)
		end

		-- ===================================================================
		-- DEBUGGING AND UTILITY COMMANDS
		-- ===================================================================

		-- Command to kill duplicate LSP clients
		vim.api.nvim_create_user_command("KillDuplicateLSP", function()
			local all_clients = vim.lsp.get_clients()
			local by_name_and_root = {}
			local killed = 0

			-- Group clients by name and root directory
			for _, client in ipairs(all_clients) do
				local key = string.format("%s:%s", client.name, client.config.root_dir or "none")
				by_name_and_root[key] = by_name_and_root[key] or {}
				table.insert(by_name_and_root[key], client)
			end

			-- Kill duplicates (keep the first one)
			for key, clients in pairs(by_name_and_root) do
				if #clients > 1 then
					print(string.format("🔫 Found %d duplicate %s clients", #clients, clients[1].name))
					-- Keep the first client, kill the rest
					for i = 2, #clients do
						local client = clients[i]
						print(string.format("   Killing client ID: %d", client.id))
						vim.lsp.stop_client(client.id, true)
						killed = killed + 1
					end
				end
			end

			if killed > 0 then
				print(string.format("✅ Killed %d duplicate LSP clients", killed))
				print("💡 Restart Neovim to ensure clean state, or run :LspRestart")
			else
				print("✅ No duplicate LSP clients found")
			end
		end, { desc = "Kill duplicate LSP client instances" })

		-- Command to check for duplicate LSP clients
		vim.api.nvim_create_user_command("CheckDuplicateLSP", function()
			local all_clients = vim.lsp.get_clients()
			local by_name = {}

			for _, client in ipairs(all_clients) do
				by_name[client.name] = by_name[client.name] or {}
				table.insert(by_name[client.name], client)
			end

			print("=== DUPLICATE LSP CHECK ===")
			for name, clients in pairs(by_name) do
				if #clients > 1 then
					print(string.format("🚨 MULTIPLE %s instances found:", name))
					for _, client in ipairs(clients) do
						print(string.format("  ID: %d, Root: %s", client.id, client.config.root_dir or "none"))
					end
				else
					print(string.format("✅ %s: 1 instance", name))
				end
			end
		end, { desc = "Check for duplicate LSP client instances" })

		-- Command to check LSP client information
		vim.api.nvim_create_user_command("LspClientInfo", function()
			local bufnr = vim.api.nvim_get_current_buf()
			local clients = vim.lsp.get_clients({ bufnr = bufnr })

			print("=== LSP CLIENT INFO ===")
			print(string.format("Buffer: %d", bufnr))
			print(string.format("Active clients: %d", #clients))

			for _, client in ipairs(clients) do
				print(string.format("Client: %s (ID: %d)", client.name, client.id))
				print(string.format("  Root dir: %s", client.config.root_dir or "none"))
				print(string.format("  Cmd: %s", vim.inspect(client.config.cmd)))
				print(string.format("  Namespace: %d", vim.lsp.diagnostic.get_namespace(client.id)))
				print("")
			end
		end, { desc = "Show LSP client information" })

		-- Standard LSP status command
		vim.api.nvim_create_user_command("LspStatus", function()
			local clients = vim.lsp.get_clients()
			if #clients == 0 then
				print("No active LSP clients")
				return
			end

			for _, client in ipairs(clients) do
				if type(client) == "table" and client.name then
					local buffers = {}
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if vim.lsp.buf_is_attached(buf, client.id) then
							table.insert(buffers, tostring(buf))
						end
					end

					print(
						string.format(
							"LSP %s (id: %s) attached to buffers: %s",
							tostring(client.name),
							tostring(client.id),
							table.concat(buffers, ", ")
						)
					)
				end
			end
		end, { desc = "Show LSP status" })
	end,
}
