return {
	"stevearc/conform.nvim",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			notify_on_error = true,

			formatters = {
				sqlfluff = {
					command = "sqlfluff",
					args = {
						"fix",
						"--dialect",
						"ansi", -- change to mysql/postgres as needed
						"--config",
						vim.fn.stdpath("config") .. "/.sqlfluff",
						"-",
					},
					stdin = true,
					-- cwd removed: getcwd() is conform's default
					-- exit_codes removed: code 1 means unfixable violations, not success
				},
			},

			formatters_by_ft = {
				markdown = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				json = { "jq" },
				lua = { "stylua" },
				go = { "gofumpt", "goimports" }, -- was missing
				sql = { "sqlfluff" },
				mysql = { "sqlfluff" },
				postgresql = { "sqlfluff" },
				tex = { "latexindent" },
				-- python  = { "isort", "black" }, -- uncomment when needed
			},

			-- Use format_after_save only (format_on_save removed to avoid double formatting)
			format_after_save = {
				lsp_fallback = true,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 5000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
