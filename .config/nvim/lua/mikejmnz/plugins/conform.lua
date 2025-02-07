-- return {
-- 	"stevearc/conform.nvim",
-- 	event = { "BufWritePre" }, -- Keep this if you want formatting on save
-- 	cmd = { "ConformInfo" },
-- 	opts = {
-- 		formatters_by_ft = { -- For direct conform.format() calls
-- 			sql = { "sqlfluff" },
-- 			mysql = { "sqlfluff" },
-- 			postgresql = { "sqlfluff" },
-- 		},
-- 		formatters = {
-- 			sqlfluff = {
-- 				command = "sqlfluff",
-- 				args = function(params)
-- 					local dialect = "mysql" -- Default
-- 					if params.filetype == "postgresql" then
-- 						dialect = "postgres"
-- 					elseif params.filetype == "sql" then
-- 						dialect = "ansi" -- or another appropriate generic dialect
-- 					end
-- 					return { "fix", "--dialect", dialect, "-" } -- Only these arguments
-- 				end,
-- 				stdin = true, -- Crucial: Ensure stdin is always used
-- 			},
-- 		},
-- 		-- Crucial: Tell conform to handle LSP formatting
-- 		lsp_format_enable = true, -- Enable LSP formatting through conform
-- 		lsp_format_fallback = true, -- Fallback to conform if LSP doesn't provide formatting
-- 	},
-- 	keys = {
-- 		{
-- 			"<leader>f",
-- 			function()
-- 				require("conform").format({ async = true, lsp_fallback = true })
-- 			end,
-- 			mode = { "n", "v" },
-- 			desc = "Format buffer",
-- 		},
-- 	},
-- }
return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" }, -- Important for formatting on save
	opts = {
		formatters = {
			sqlfluff = {
				command = "/Users/miguel.jimenez2/.local/share/nvim/mason/bin/sqlfluff", -- EXACT path from `which sqlfluff`
				args = { "fix", "--dialect", "mysql", "-" },
				stdin = true,
				prepend_args = true,
				cwd = function(params)
					return vim.fn.getcwd()
				end,
			},
			stylua = {
				command = "stylua",
				stdin = true,
			},
			black = {
				command = "black",
			},
			-- ... other formatters as needed ...
		},
		formatters_by_ft = {
			lua = { "stylua" }, -- ONLY stylua for Lua files
			sql = { "sqlfluff" }, -- ONLY sqlfluff for SQL files
			mysql = { "sqlfluff" }, -- ONLY sqlfluff for MySQL files
			postgresql = { "sqlfluff" }, -- ONLY sqlfluff for PostgreSQL files
			python = { "black" }, -- ONLY black for Python files
			-- ... other filetype mappings as needed ...
		},
		lsp_format_enable = true, -- If you want LSP formatting to use conform
		lsp_format_fallback = true, -- If LSP formatting fails, use conform
	},
}
