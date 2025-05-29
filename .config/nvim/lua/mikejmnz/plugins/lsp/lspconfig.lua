-- return {
-- 	"neovim/nvim-lspconfig",
-- 	event = { "BufReadPre", "BufNewFile" },
-- 	dependencies = {
-- 		"hrsh7th/cmp-nvim-lsp",
-- 		{ "antosha417/nvim-lsp-file-operations", config = true },
-- 	},
-- 	config = function()
-- 		-- import lspconfig plugin
-- 		local lspconfig = require("lspconfig")
--
-- 		-- import cmp-nvim-lsp plugin
-- 		local cmp_nvim_lsp = require("cmp_nvim_lsp")
--
-- 		local keymap = vim.keymap -- for conciseness
--
-- 		---@param client vim.lsp.Client
-- 		---@param bufnr integer
-- 		local on_attach = function(client, bufnr)
-- 			local opts = { noremap = true, silent = true, buffer = bufnr }
--
-- 			-- set keybinds
-- 			opts.desc = "Show LSP references"
-- 			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references
--
-- 			opts.desc = "Go to declaration"
-- 			keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration
--
-- 			opts.desc = "Show LSP definitions"
-- 			keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions
--
-- 			opts.desc = "Show LSP implementations"
-- 			keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations
--
-- 			opts.desc = "Show LSP type definitions"
-- 			keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions
--
-- 			opts.desc = "See available code actions"
-- 			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection
--
-- 			opts.desc = "Smart rename"
-- 			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename
--
-- 			opts.desc = "Show buffer diagnostics"
-- 			keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file
--
-- 			opts.desc = "Show line diagnostics"
-- 			keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line
--
-- 			opts.desc = "Go to previous diagnostic"
-- 			keymap.set("n", "[d", function()
-- 				vim.diagnostic.jump({ count = -1 })
-- 			end, opts)
--
-- 			opts.desc = "Go to next diagnostic"
-- 			keymap.set("n", "]d", function()
-- 				vim.diagnostic.jump({ count = 1 })
-- 			end, opts)
--
-- 			opts.desc = "Show documentation for what is under cursor"
-- 			keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor
--
-- 			opts.desc = "Restart LSP"
-- 			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
-- 		end
--
-- 		-- used to enable autocompletion (assign to every lsp server config)
-- 		local capabilities = cmp_nvim_lsp.default_capabilities()
--
-- 		-- Improve diagnostic configuration for better stability
-- 		vim.diagnostic.config({
-- 			virtual_text = {
-- 				spacing = 4,
-- 				source = "if_many",
-- 				prefix = "●",
-- 			},
-- 			signs = true,
-- 			underline = true,
-- 			update_in_insert = false, -- Don't update diagnostics in insert mode
-- 			severity_sort = true,
-- 			float = {
-- 				border = "rounded",
-- 				source = true,
-- 				header = "",
-- 				prefix = "",
-- 				focusable = false,
-- 			},
-- 		})
--
-- 		-- Change the Diagnostic symbols in the sign column (gutter)
-- 		-- (not in youtube nvim video)
-- 		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
-- 		for type, icon in pairs(signs) do
-- 			local hl = "DiagnosticSign" .. type
-- 			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
-- 		end
--
-- 		-- Improved autocommands for better LSP stability
-- 		local lsp_group = vim.api.nvim_create_augroup("LspDiagnostics", { clear = true })
--
-- 		vim.api.nvim_create_autocmd("LspAttach", {
-- 			group = lsp_group,
-- 			callback = function(ev)
-- 				local client = vim.lsp.get_client_by_id(ev.data.client_id)
-- 				if client then
-- 					-- Ensure diagnostics are enabled for this buffer
-- 					vim.diagnostic.enable(ev.buf)
-- 					print(
-- 						string.format(
-- 							"LSP %s successfully attached to buffer %d (filetype: %s)",
-- 							client.name,
-- 							ev.buf,
-- 							vim.bo[ev.buf].filetype
-- 						)
-- 					)
-- 				end
-- 			end,
-- 		})
--
-- 		vim.api.nvim_create_autocmd("LspDetach", {
-- 			group = lsp_group,
-- 			callback = function(ev)
-- 				local client = vim.lsp.get_client_by_id(ev.data.client_id)
-- 				if client then
-- 					print(string.format("LSP %s detached from buffer %d", client.name, ev.buf))
-- 				end
-- 			end,
-- 		})
--
-- 		-- Ensure diagnostics persist across buffer changes
-- 		vim.api.nvim_create_autocmd("BufEnter", {
-- 			group = lsp_group,
-- 			callback = function(ev)
-- 				-- Small delay to ensure LSP is ready
-- 				vim.defer_fn(function()
-- 					if vim.api.nvim_buf_is_valid(ev.buf) then
-- 						vim.diagnostic.enable(ev.buf)
-- 					end
-- 				end, 100)
-- 			end,
-- 		})
--
-- 		-- Update signs configuration for newer Neovim versions
-- 		vim.diagnostic.config({
-- 			signs = {
-- 				text = {
-- 					[vim.diagnostic.severity.ERROR] = signs.Error,
-- 					[vim.diagnostic.severity.WARN] = signs.Warn,
-- 					[vim.diagnostic.severity.HINT] = signs.Hint,
-- 					[vim.diagnostic.severity.INFO] = signs.Info,
-- 				},
-- 			},
-- 		})
--
-- 		lspconfig["htmx-lsp"].setup({
-- 			capabilities = capabilities,
-- 			on_attach = on_attach, -- Make sure the on_attach function is called
-- 		})
--
-- 		-- configure typescript server with plugin
-- 		-- lspconfig["tsserver"].setup({
-- 		--   capabilities = capabilities,
-- 		--   on_attach = on_attach,
-- 		-- })
--
-- 		-- configure css server
-- 		-- lspconfig["cssls"].setup({
-- 		--   capabilities = capabilities,
-- 		--   on_attach = on_attach,
-- 		-- })
--
-- 		-- configure tailwindcss server
-- 		-- lspconfig["tailwindcss"].setup({
-- 		--   capabilities = capabilities,
-- 		--   on_attach = on_attach,
-- 		-- })
--
-- 		-- configure svelte server
-- 		-- lspconfig["svelte"].setup({
-- 		--   capabilities = capabilities,
-- 		--   on_attach = function(client, bufnr)
-- 		--     on_attach(client, bufnr)
-- 		--
-- 		--     vim.api.nvim_create_autocmd("BufWritePost", {
-- 		--       pattern = { "*.js", "*.ts" },
-- 		--       callback = function(ctx)
-- 		--         if client.name == "svelte" then
-- 		--           client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
-- 		--         end
-- 		--       end,
-- 		--     })
-- 		--   end,
-- 		-- })
--
-- 		-- configure prisma orm server
-- 		-- lspconfig["prismals"].setup({
-- 		--   capabilities = capabilities,
-- 		--   on_attach = on_attach,
-- 		-- })
--
-- 		-- configure graphql language server
-- 		-- lspconfig["graphql"].setup({
-- 		--   capabilities = capabilities,
-- 		--   on_attach = on_attach,
-- 		--   filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
-- 		-- })
--
-- 		-- configure emmet language server
-- 		-- lspconfig["emmet_ls"].setup({
-- 		--   capabilities = capabilities,
-- 		--   on_attach = on_attach,
-- 		--   filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
-- 		-- })
--
-- 		-- Python virtual env detection
-- 		-- local util = require("lspconfig/util")
-- 		-- local path = util.path
-- 		-- local function file_exists(name)
-- 		-- 	local f = io.open(name, "r")
-- 		-- 	if f ~= nil then
-- 		-- 		io.close(f)
-- 		-- 		return true
-- 		-- 	else
-- 		-- 		return false
-- 		-- 	end
-- 		-- end
-- 		-- local function get_python_path(workspace)
-- 		-- 	-- Use activated virtualenv.
-- 		-- 	if vim.env.VIRTUAL_ENV then
-- 		-- 		return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
-- 		-- 	end
-- 		--
-- 		-- 	-- Find and use virtualenv in workspace directory.
-- 		-- 	for _, pattern in ipairs({ "*", ".*" }) do
-- 		-- 		local match = vim.fn.glob(path.join(workspace, pattern, "pyvenv.cfg"))
-- 		-- 		if match ~= "" then
-- 		-- 			return path.join(path.dirname(match), "bin", "python")
-- 		-- 		end
-- 		-- 	end
-- 		--
-- 		-- 	local default_venv_path = path.join(
-- 		-- 		vim.env.HOME,
-- 		-- 		"virtualenvs",
-- 		-- 		"nvim-venv",
-- 		-- 		"bin",
-- 		-- 		"python",
-- 		-- 		"~/Documents/localDocuments/Jira_Reports"
-- 		-- 	)
-- 		-- 	if file_exists(default_venv_path) then
-- 		-- 		return default_venv_path
-- 		-- 	end
-- 		--
-- 		-- 	-- Default virtual environment
-- 		-- 	--   return path.join(vim.env.HOME, "virtualenvs", "nvim-venv", "bin", "python")
-- 		--
-- 		-- 	-- Fallback to system Python.
-- 		-- 	return util.exepath("python3") or util.exepath("python") or "python"
-- 		-- end
--
-- 		lspconfig["pyright"].setup({
-- 			capabilities = capabilities,
-- 			on_attach = on_attach,
--
-- 			-- Python virtual env detection
-- 			-- lspconfig.util.path
-- 			-- before_init = function(_, config)
-- 			-- 	config.settings.python.pythonPath = get_python_path(config.root_dir)
-- 			-- end,
-- 			settings = {
-- 				python = {
-- 					analysis = {
-- 						autoSearchPaths = true,
-- 						extraPaths = { "~/Documents/localDocuments/" },
-- 					},
-- 				},
-- 			},
-- 		})
--
-- 		-- configure lua server (with special settings)
-- 		lspconfig["lua_ls"].setup({
-- 			capabilities = capabilities,
-- 			on_attach = on_attach,
-- 			settings = { -- custom settings for lua
-- 				Lua = {
-- 					-- make the language server recognize "vim" global
-- 					diagnostics = {
-- 						globals = { "vim" },
-- 					},
-- 					workspace = {
-- 						-- make language server aware of runtime files
-- 						library = {
-- 							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
-- 							[vim.fn.stdpath("config") .. "/lua"] = true,
-- 						},
-- 						checkThirdParty = false,
-- 					},
-- 					runtime = {
-- 						version = "LuaJIT",
-- 						path = vim.split(package.path, ";"),
-- 					},
-- 				},
-- 			},
-- 		})
--
-- 		lspconfig["jqls"].setup({
-- 			capabilities = capabilities,
-- 			on_attach = on_attach,
-- 		})
--
-- 		-- configure gopls server
-- 		lspconfig["gopls"].setup({
-- 			capabilities = capabilities,
-- 			on_attach = on_attach,
-- 		})
--
-- 		lspconfig["templ"].setup({
-- 			capabilities = capabilities,
-- 			on_attach = on_attach,
-- 			cmd = { "templ", "lsp" },
-- 			filetypes = { "html", "templ" },
-- 		})
-- 		-- lspconfig["htmx-lsp"].setup({
-- 		-- 	capabilities = capabilities,
-- 		-- 	on_attach = on_attach,
-- 		-- })
-- 		-- lspconfig["sqls"].setup({
-- 		--   capabilities = capabilities,
-- 		--   on_attach = function(client, bufnr)
-- 		--     -- Ensure `on_attach` is actually defined before calling it
-- 		--     if on_attach then
-- 		--       on_attach(client, bufnr)
-- 		--     end
-- 		--   end,
-- 		--   cmd = { "sqls" }, -- Remove unnecessary "up" argument
-- 		--   filetypes = { "sql", "mysql", "postgresql" },
-- 		--   root_dir = function(fname)
-- 		--     local util = require("lspconfig.util")
-- 		--     return util.root_pattern(".git")(fname)
-- 		--         or util.root_pattern("init.sql", "schema.sql")(fname)
-- 		--         or vim.fn.getcwd()
-- 		--   end,
-- 		--   settings = {
-- 		--     sqls = {
-- 		--       format = false,
-- 		--       defaultDriver = 'mysql',
-- 		--       connections = {}, -- Ensure this is correctly set if needed
-- 		--     },
-- 		--   },
-- 		-- })
--
-- 		lspconfig["sqls"].setup({
-- 			capabilities = capabilities,
-- 			on_attach = function(client, bufnr)
-- 				if on_attach then
-- 					on_attach(client, bufnr)
-- 				end
-- 			end,
-- 			cmd = { "sqls" },
-- 			filetypes = { "sql", "mysql", "postgresql" },
-- 			root_dir = function(fname)
-- 				local util = require("lspconfig.util")
-- 				return util.root_pattern(".git")(fname)
-- 					or util.root_pattern("init.sql", "schema.sql")(fname)
-- 					or vim.fn.getcwd()
-- 			end,
-- 			settings = {
-- 				sqls = {
-- 					format = false,
-- 					defaultDriver = "mysql",
-- 					connections = {}, -- Define your connections here if needed
-- 				},
-- 			},
-- 			handlers = {
-- 				["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
-- 					if result and result.diagnostics then
-- 						for _, diagnostic in ipairs(result.diagnostics) do
-- 							print("SQLS LSP:", diagnostic.message)
-- 						end
-- 					end
-- 					return vim.lsp.handlers["textDocument/publishDiagnostics"](_, result, ctx, config)
-- 				end,
-- 			},
-- 		})
--
-- 		-- Add command to check LSP status
-- 		vim.api.nvim_create_user_command("LspStatus", function()
-- 			local clients = vim.lsp.get_clients()
-- 			if #clients == 0 then
-- 				print("No active LSP clients")
-- 			else
-- 				for _, client in ipairs(clients) do
-- 					local buffers = {}
-- 					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
-- 						if vim.lsp.buf_is_attached(buf, client.id) then
-- 							table.insert(buffers, buf)
-- 						end
-- 					end
-- 					print(
-- 						string.format(
-- 							"LSP %s (id: %d) attached to buffers: %s",
-- 							client.name,
-- 							client.id,
-- 							table.concat(buffers, ", ")
-- 						)
-- 					)
-- 				end
-- 			end
-- 		end, {})
--
-- 		-- Command to refresh diagnostics manually
-- 		vim.api.nvim_create_user_command("DiagnosticRefresh", function()
-- 			vim.diagnostic.reset()
-- 			for _, client in ipairs(vim.lsp.get_clients()) do
-- 				client.request("textDocument/diagnostic", {
-- 					textDocument = vim.lsp.util.make_text_document_params(),
-- 				})
-- 			end
-- 		end, {})
-- 	end,
-- }
return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		local lspconfig = require("lspconfig")
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
				focusable = false,
			},
		})

		-- Diagnostic signs - avoid reserved word 'type'
		local diagnostic_signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }

		for sign_name, icon in pairs(diagnostic_signs) do
			local hl = "DiagnosticSign" .. sign_name
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		local lsp_group = vim.api.nvim_create_augroup("LspDiagnosticsMinimal", { clear = true })

		-- Basic LSP attach notification
		vim.api.nvim_create_autocmd("LspAttach", {
			group = lsp_group,
			callback = function(ev)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				if client then
					print(string.format("LSP %s attached to buffer %d", client.name, ev.buf))
				end
			end,
		})

		-- Clear diagnostics on buffer delete
		vim.api.nvim_create_autocmd("BufDelete", {
			group = lsp_group,
			callback = function(ev)
				if vim.api.nvim_buf_is_valid(ev.buf) then
					vim.diagnostic.reset(nil, ev.buf)
				end
			end,
		})

		-- Simple paste/text change handling - just clear duplicates
		vim.api.nvim_create_autocmd("TextChanged", {
			group = lsp_group,
			callback = function(ev)
				-- Clear diagnostics immediately on large text changes (like paste)
				local buf = ev.buf
				local line_count = vim.api.nvim_buf_line_count(buf)

				-- If buffer has many lines, assume it might be a paste operation
				if line_count > 50 then
					vim.diagnostic.reset(nil, buf)
				end
			end,
		})

		-- Clear diagnostics when entering a buffer to prevent accumulation
		vim.api.nvim_create_autocmd("BufEnter", {
			group = lsp_group,
			callback = function(ev)
				-- Only clear if there are duplicate-looking diagnostics
				local diagnostics = vim.diagnostic.get(ev.buf)
				if #diagnostics > 20 then -- Arbitrary threshold for "too many diagnostics"
					vim.diagnostic.reset(nil, ev.buf)
				end
			end,
		})
		vim.api.nvim_create_autocmd("LspDetach", {
			group = lsp_group,
			callback = function(ev)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				if client and type(client) == "table" then
					local client_name = tostring(client.name or "unknown")
					print(string.format("LSP %s detached from buffer %d", client_name, ev.buf))
				end
			end,
		})

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

		-- LSP server configurations
		local servers = {
			-- ["htmx-lsp"] = { capabilities = capabilities, on_attach = on_attach },
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
				root_dir = function(fname)
					local util = require("lspconfig.util")
					return util.root_pattern(".git")(fname)
						or util.root_pattern("init.sql", "schema.sql")(fname)
						or vim.fn.getcwd()
				end,
				settings = {
					sqls = {
						format = false,
						defaultDriver = "mysql",
						connections = {},
					},
				},
			},
		}

		-- Setup all servers
		for server_name, config in pairs(servers) do
			if lspconfig[server_name] then
				lspconfig[server_name].setup(config)
			end
		end

		-- Commands
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

		vim.api.nvim_create_user_command("DiagnosticRefresh", function()
			vim.diagnostic.reset()
			print("Diagnostics reset - they will be regenerated automatically")
		end, { desc = "Reset diagnostics" })

		-- Add this to your lspconfig.lua file, replacing the duplicate prevention section
		-- Enhanced duplicate prevention system
		local duplicate_prevention = vim.api.nvim_create_augroup("DiagnosticDuplicatePrevention", { clear = true })

		-- Track the last diagnostic count per buffer to detect duplicates
		local diagnostic_tracker = {}

		-- Manual duplicate cleanup with better safety checks
		local function remove_duplicate_diagnostics_manual(bufnr)
			if not vim.api.nvim_buf_is_valid(bufnr) then
				return false
			end

			local current_diagnostics = vim.diagnostic.get(bufnr)
			local current_count = #current_diagnostics

			if current_count == 0 then
				print("No diagnostics found in buffer")
				return false
			end

			-- Find exact duplicates only
			local unique_diagnostics = {}
			local seen_exact_matches = {}
			local duplicate_count = 0

			for _, diagnostic in ipairs(current_diagnostics) do
				-- Create a strict key for exact duplicate detection
				local key = string.format(
					"%d:%d:%d:%s",
					diagnostic.lnum or 0,
					diagnostic.col or 0,
					diagnostic.severity or 1,
					diagnostic.message or ""
				)

				if seen_exact_matches[key] then
					-- This is an exact duplicate - count it
					duplicate_count = duplicate_count + 1
				else
					-- First time seeing this diagnostic - keep it
					seen_exact_matches[key] = true
					table.insert(unique_diagnostics, diagnostic)
				end
			end

			-- Only proceed if we found actual duplicates
			if duplicate_count == 0 then
				print("No exact duplicates found")
				return false
			end

			-- Store original diagnostics in case we need to restore
			local original_diagnostics = vim.deepcopy(current_diagnostics)

			-- Clear and replace with unique diagnostics
			vim.diagnostic.reset(nil, bufnr)

			-- Set unique diagnostics back
			vim.defer_fn(function()
				if vim.api.nvim_buf_is_valid(bufnr) then
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
										current_count,
										#unique_diagnostics
									)
								)
								return true
							end
						end
					end
					-- Fallback: restore original if we can't find proper namespace
					print("Warning: Could not find LSP namespace, diagnostics may not persist")
				end
			end, 100)

			return true
		end

		-- DISABLE AUTOMATIC CLEANING - Make it manual only
		-- Automatic cleaning was interfering with normal diagnostics

		-- Conservative automatic duplicate prevention (re-enabled)
		-- Only triggers when there are obvious duplicates

		-- Function to clean duplicates automatically (conservative)
		local function auto_clean_duplicates(bufnr)
			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end

			local diagnostics = vim.diagnostic.get(bufnr)
			local count = #diagnostics

			-- Only act if there are many diagnostics (suggesting duplication)
			if count < 6 then
				return
			end

			local unique = {}
			local seen_keys = {}
			local removed_count = 0

			for _, diagnostic in ipairs(diagnostics) do
				-- Same deduplication logic as telescope
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

			-- Only clean if we found significant duplicates (at least 2)
			if removed_count >= 2 then
				-- Clear and set clean diagnostics
				vim.diagnostic.reset(nil, bufnr)

				local clients = vim.lsp.get_clients({ bufnr = bufnr })
				if #clients > 0 then
					local ns = vim.lsp.diagnostic.get_namespace(clients[1].id)
					vim.diagnostic.set(ns, bufnr, unique)
					print(string.format("🔧 Auto-cleaned %d duplicate diagnostics", removed_count))
				end
			end
		end

		-- Monitor for diagnostic duplicates (conservative)
		vim.api.nvim_create_autocmd("DiagnosticChanged", {
			group = duplicate_prevention,
			callback = function(ev)
				-- Only check occasionally and with delay
				vim.defer_fn(function()
					auto_clean_duplicates(ev.buf)
				end, 1000) -- Long delay to avoid interference
			end,
		})

		-- Enhanced diagnostic configuration
		vim.diagnostic.config({
			virtual_text = {
				spacing = 4,
				source = "if_many",
				prefix = "●",
				format = function(diagnostic)
					-- Ensure consistent message format
					local message = diagnostic.message:gsub("%s+", " ")
					message = message:gsub("^%s*(.-)%s*$", "%1")
					return message
				end,
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
				focusable = false,
				format = function(diagnostic)
					-- Clean up float messages too - store result to avoid multiple returns
					local message = diagnostic.message:gsub("%s+", " ")
					message = message:gsub("^%s*(.-)%s*$", "%1")
					return message
				end,
			},
		})

		-- Command to manually force cleanup of all buffers
		vim.api.nvim_create_user_command("DiagnosticCleanAll", function()
			local cleaned_buffers = 0
			local total_removed = 0

			for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
					local before = #vim.diagnostic.get(bufnr)
					if before > 0 then
						local success = remove_duplicate_diagnostics_manual(bufnr)
						if success then
							vim.defer_fn(function()
								local after = #vim.diagnostic.get(bufnr)
								if before > after then
									cleaned_buffers = cleaned_buffers + 1
									total_removed = total_removed + (before - after)
								end
							end, 200)
						end
					end
				end
			end

			vim.defer_fn(function()
				if cleaned_buffers > 0 then
					print(
						string.format(
							"Cleaned %d buffers, removed %d duplicate diagnostics",
							cleaned_buffers,
							total_removed
						)
					)
				else
					print("No duplicate diagnostics found in any buffer")
				end
			end, 1000)
		end, { desc = "Manually clean duplicate diagnostics from all buffers" })
	end,
}
