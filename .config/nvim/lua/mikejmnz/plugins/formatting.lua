return {
	"stevearc/conform.nvim",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
	config = function()
		local conform = require("conform")

		conform.setup({
			notify_on_error = true,
			formatters = {
				sqlfluff = {
					-- command = "/Users/miguel.jimenez2/.local/share/nvim/mason/bin/sqlfluff",
					command = "sqlfluff",
					args = {
						"fix",
						"--rules",
						"all",
						"--config",
						"/Users/miguel.jimenez2/.dotfiles/.config/nvim/.sqlfluff", -- Explicitly set the config path
						"-",
					},
					stdin = true,
					cwd = function(args)
						return vim.fn.getcwd()
					end,
					exit_codes = { 0, 1 },
				},
				stylua = {
					command = "stylua",
					args = { "-" },
					stdin = true,
				},
				-- black = {
				-- 	command = "black",
				-- 	args = { "--quiet", "-" },
				-- 	stdin = true,
				-- },
				-- -- ... other formatters as needed ...
			},
			formatters_by_ft = {
				markdown = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				json = { "jq" },
				lua = { "stylua" },
				sql = { "sqlfluff" }, -- ONLY sqlfluff for SQL files
				mysql = { "sqlfluff" }, -- ONLY sqlfluff for MySQL files
				postgresql = { "sqlfluff" }, -- ONLY sqlfluff for PostgreSQL files
				tex = { "latexindent" },
				-- python = { "isort", "black" },
			},
			-- 	-- Modified format_on_save configuration
			-- 	format_on_save = function(bufnr)
			-- 		-- Disable with a global or buffer-local variable
			-- 		if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
			-- 			return
			-- 		end
			-- 		return {
			-- 			timeout_ms = 10000,
			-- 			lsp_fallback = true,
			-- 			async = true,
			-- 		}
			-- 	end,
			-- Replace format_on_save with format_after_save
			format_after_save = {
				lsp_fallback = true,
				timeout_ms = 20000,
			},
			-- Remove async from format_on_save
			-- format_on_save = {
			--   lsp_fallback = true,
			--   timeout_ms = 20000,
			--   -- quiet = true,
			-- },

			format_on_save = function(bufnr)
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end

				vim.cmd("write") -- Ensure buffer is saved before formatting

				return {
					timeout_ms = 20000,
					lsp_fallback = true,
				}
			end,
			-- Add this callback to handle the format result
			callback = function(err)
				if err then
					vim.notify(err, vim.log.levels.ERROR)
				end
			end,
		})

		-- Manual format mapping
		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 5000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
