return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local keymap = vim.keymap

		local on_attach = function(_, bufnr)
			local opts = { noremap = true, silent = true, buffer = bufnr }

			-- LSP keybinds
			-- NOTE: [d, ]d, and <leader>d are defined globally in keymaps.lua
			-- They are intentionally NOT defined here to avoid buffer-local override
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
				"K",
				vim.lsp.buf.hover,
				vim.tbl_extend("force", opts, { desc = "Show documentation for what is under cursor" })
			)

			-- NOTE: :LspRestart is the legacy alias (Nvim 0.11 and older).
			-- On Nvim 0.12+, the correct command is :lsp restart.
			keymap.set(
				"n",
				"<leader>rs",
				"<cmd>lsp restart<CR>",
				vim.tbl_extend("force", opts, { desc = "Restart LSP" })
			)
		end

		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Single consolidated diagnostic config.
		-- Previously two separate calls existed here — merged into one.
		-- sign_define() removed: not supported in Neovim 0.12+.
		vim.diagnostic.config({
			virtual_text = {
				spacing = 4,
				source = "if_many",
				prefix = "●",
			},
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
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

		-- ===================================================================
		-- LSP SERVER CONFIGURATIONS
		-- ===================================================================

		local servers = {
			["htmx"] = {
				capabilities = capabilities,
				on_attach = on_attach,
			},

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
						-- diagnostics.globals and workspace.library omitted:
						-- lazydev.nvim handles these automatically
						runtime = { version = "LuaJIT" },
						telemetry = { enable = false },
						workspace = { checkThirdParty = false },
					},
				},
			},

			["jqls"] = {
				capabilities = capabilities,
				on_attach = on_attach,
			},

			["gopls"] = {
				capabilities = capabilities,
				on_attach = on_attach,
			},

			["templ"] = {
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { "templ", "lsp" },
				filetypes = { "templ" },
			},

			["sqls"] = {
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = { "sqls" },
				filetypes = { "sql", "mysql", "postgresql" },
				root_dir = function(fname)
					-- getcwd() fallback removed: caused sqls to attach in unrelated projects
					return vim.fs.root(fname, { ".git", "init.sql", "schema.sql" })
				end,
				settings = {
					sqls = {
						format = false,
						defaultDriver = "mysql",
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

		-- Single source of truth for enabling LSP servers.
		-- mason-lspconfig is NOT used to avoid double vim.lsp.enable() calls.
		for server_name, config in pairs(servers) do
			vim.lsp.config(server_name, config)
			vim.lsp.enable(server_name)
		end

		-- ===================================================================
		-- UTILITY COMMANDS
		-- ===================================================================

		vim.api.nvim_create_user_command("KillDuplicateLSP", function()
			local all_clients = vim.lsp.get_clients()
			local by_name_and_root = {}
			local killed = 0

			for _, client in ipairs(all_clients) do
				local key = string.format("%s:%s", client.name, client.config.root_dir or "none")
				by_name_and_root[key] = by_name_and_root[key] or {}
				table.insert(by_name_and_root[key], client)
			end

			for _, clients in pairs(by_name_and_root) do
				if #clients > 1 then
					vim.notify(
						string.format("Found %d duplicate %s clients", #clients, clients[1].name),
						vim.log.levels.WARN
					)
					for i = 2, #clients do
						clients[i]:stop(true)
						killed = killed + 1
					end
				end
			end

			if killed > 0 then
				vim.notify(
					string.format("Killed %d duplicate LSP clients. Run :lsp restart to restore clean state.", killed),
					vim.log.levels.INFO
				)
			else
				vim.notify("No duplicate LSP clients found", vim.log.levels.INFO)
			end
		end, { desc = "Kill duplicate LSP client instances" })

		vim.api.nvim_create_user_command("CheckDuplicateLSP", function()
			local all_clients = vim.lsp.get_clients()
			local by_name = {}

			for _, client in ipairs(all_clients) do
				by_name[client.name] = by_name[client.name] or {}
				table.insert(by_name[client.name], client)
			end

			local lines = { "=== DUPLICATE LSP CHECK ===" }
			for name, clients in pairs(by_name) do
				if #clients > 1 then
					table.insert(lines, string.format("MULTIPLE %s instances found:", name))
					for _, client in ipairs(clients) do
						table.insert(
							lines,
							string.format("  ID: %d, Root: %s", client.id, client.config.root_dir or "none")
						)
					end
				else
					table.insert(lines, string.format("OK: %s (1 instance)", name))
				end
			end

			vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
		end, { desc = "Check for duplicate LSP client instances" })

		vim.api.nvim_create_user_command("LspClientInfo", function()
			local bufnr = vim.api.nvim_get_current_buf()
			local clients = vim.lsp.get_clients({ bufnr = bufnr })
			local lines = {
				"=== LSP CLIENT INFO ===",
				string.format("Buffer: %d | Active clients: %d", bufnr, #clients),
			}

			for _, client in ipairs(clients) do
				table.insert(
					lines,
					string.format("  %s (ID: %d) | Root: %s", client.name, client.id, client.config.root_dir or "none")
				)
			end

			vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
		end, { desc = "Show LSP client information for current buffer" })

		vim.api.nvim_create_user_command("LspStatus", function()
			local clients = vim.lsp.get_clients()
			if #clients == 0 then
				vim.notify("No active LSP clients", vim.log.levels.WARN)
				return
			end

			local lines = {}
			for _, client in ipairs(clients) do
				if type(client) == "table" and client.name then
					local buffers = {}
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if vim.lsp.buf_is_attached(buf, client.id) then
							table.insert(buffers, tostring(buf))
						end
					end
					table.insert(
						lines,
						string.format(
							"%s (id: %d) → buffers: [%s]",
							client.name,
							client.id,
							table.concat(buffers, ", ")
						)
					)
				end
			end

			vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
		end, { desc = "Show LSP status" })
	end,
}
