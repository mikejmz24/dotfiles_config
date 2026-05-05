return {
	"stevearc/conform.nvim",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			notify_on_error = true,

			-- default_format_opts applies to all format() calls unless overridden.
			-- lsp_format = "fallback" replaces deprecated lsp_fallback = true.
			default_format_opts = {
				lsp_format = "fallback",
			},

			formatters = {
				sqlfluff = {
					command = "sqlfluff",
					args = {
						"fix",
						-- dialect removed: controlled by .sqlfluff config file.
						-- Hardcoding here overrides per-project dialect settings.
						"--config",
						vim.fn.stdpath("config") .. "/.sqlfluff",
						"-",
					},
					stdin = true,
					-- Explicit timeout cap: sqlfluff is slow on large files.
					-- Without this, conform's default is too short and causes
					-- silent failures on complex SQL.
					timeout = 10000,
				},
			},

			formatters_by_ft = {
				markdown = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				json = { "jq" },
				lua = { "stylua" },
				-- goimports first: manages imports AND formats.
				-- gofumpt second: applies stricter formatting on top.
				-- Order matters — reversed causes goimports to undo gofumpt changes.
				go = { "goimports", "gofumpt" },
				sql = { "sqlfluff" },
				mysql = { "sqlfluff" },
				postgresql = { "sqlfluff" },
				tex = { "latexindent" },
				python = { "isort", "black" }, -- uncomment when needed
			},

			-- format_after_save: async, runs after the buffer is written.
			-- Preferred over format_on_save for slow formatters like sqlfluff.
			format_after_save = function(bufnr)
				-- Per-buffer or global autoformat disable toggle.
				-- Set vim.b[bufnr].disable_autoformat = true to disable for a buffer.
				-- Set vim.g.disable_autoformat = true to disable globally.
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				return {
					lsp_format = "fallback", -- replaces deprecated lsp_fallback = true
				}
			end,
		})

		-- Manual format: increased timeout for sqlfluff on large files.
		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_format = "fallback", -- replaces deprecated lsp_fallback = true
				async = false,
				timeout_ms = 10000, -- matches sqlfluff formatter timeout cap
			})
		end, { desc = "Format file or range (in visual mode)" })

		-- Toggle autoformat for current buffer.
		-- Useful when sqlfluff or other slow formatters need to be skipped.
		vim.keymap.set("n", "<leader>tf", function()
			vim.b.disable_autoformat = not vim.b.disable_autoformat
			vim.notify(
				"Autoformat " .. (vim.b.disable_autoformat and "disabled" or "enabled") .. " for this buffer",
				vim.log.levels.INFO
			)
		end, { desc = "Toggle autoformat for buffer" })

		-- Toggle autoformat globally.
		vim.keymap.set("n", "<leader>tF", function()
			vim.g.disable_autoformat = not vim.g.disable_autoformat
			vim.notify(
				"Autoformat " .. (vim.g.disable_autoformat and "disabled" or "enabled") .. " globally",
				vim.log.levels.INFO
			)
		end, { desc = "Toggle autoformat globally" })
	end,
}
