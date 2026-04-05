return {
	"mfussenegger/nvim-lint",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- Custom sqlfluff linter definition
		lint.linters.sqlfluff = {
			cmd = "sqlfluff",
			args = {
				"lint",
				"--dialect",
				"mysql",
				"--config",
				vim.fn.stdpath("config") .. "/.sqlfluff",
				"--format",
				"json",
				"-",
			},
			stdin = true,
			stream = "stdout",
			ignore_exitcode = true,
			parser = function(output)
				local diagnostics = {}
				if not output or output == "" then
					return diagnostics
				end

				local severity_map = {
					warning = vim.diagnostic.severity.WARN,
					error = vim.diagnostic.severity.ERROR,
				}

				local ok, decoded = pcall(vim.json.decode, output)
				if ok and decoded and decoded[1] and decoded[1].violations then
					for _, v in ipairs(decoded[1].violations) do
						if v.start_line_no and v.start_line_pos then
							table.insert(diagnostics, {
								lnum = v.start_line_no - 1,
								col = v.start_line_pos - 1,
								end_lnum = v.end_line_no and (v.end_line_no - 1) or nil,
								end_col = v.end_line_pos and (v.end_line_pos - 1) or nil,
								message = string.format("[%s] %s", v.code, v.description),
								severity = severity_map[v.severity] or vim.diagnostic.severity.WARN,
								source = "sqlfluff",
							})
						end
					end
				end
				return diagnostics
			end,
		}
		-- golangcilint custom definition removed: using built-in "golangci-lint" instead

		lint.linters_by_ft = {
			sql = { "sqlfluff" },
			mysql = { "sqlfluff" },
			go = { "golangci-lint" }, -- fixed: was "golangcilint" (custom, broken)
			python = { "pylint" },
			["_"] = {}, -- prevent fallback for unknown filetypes
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		-- Lint on enter and after save
		vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
			group = lint_augroup,
			callback = function()
				require("lint").try_lint()
			end,
		})

		-- Lint after leaving insert mode (debounced)
		vim.api.nvim_create_autocmd("InsertLeave", {
			group = lint_augroup,
			callback = function()
				vim.defer_fn(function()
					require("lint").try_lint()
				end, 500)
			end,
		})

		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
