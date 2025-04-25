return {
	"mfussenegger/nvim-lint",
	lazy = true,
	event = { "BufReadPre", "BufNewFile", "BufWritePost" }, -- to disable, comment this out
	config = function()
		local lint = require("lint")

		-- -- Configure sqlfluff with mysql dialect
		lint.linters.sqlfluff = {
			cmd = "sqlfluff",
			args = {
				"lint",
				"--dialect",
				"mysql",
				"--config",
				"/Users/miguel.jimenez2/.dotfiles/.config/nvim/.sqlfluff", -- Explicitly set the config path
				"--format",
				"json",
				"-", -- Read from stdin
			},
			stdin = true,
			stream = "stdout",
			ignore_exitcode = true,
			parser = function(output, bufnr)
				local diagnostics = {}
				if output and output ~= "" then
					local ok, decoded = pcall(vim.json.decode, output)
					if ok and decoded and decoded[1] and decoded[1].violations then
						for _, violation in ipairs(decoded[1].violations) do
							if violation.start_line_no and violation.start_line_pos then
								table.insert(diagnostics, {
									lnum = violation.start_line_no - 1,
									col = violation.start_line_pos - 1,
									end_lnum = violation.end_line_no and (violation.end_line_no - 1) or nil,
									end_col = violation.end_line_pos and (violation.end_line_pos - 1) or nil,
									message = string.format("[%s] %s", violation.code, violation.description),
									severity = vim.diagnostic.severity.ERROR,
									source = "sqlfluff",
								})
							end
						end
					end
				end
				return diagnostics
			end,
		}
		lint.linters.golangcilint = {
			cmd = "golangci-lint",
			args = {
				"run",
			},
			stdin = false,
			ignore_exitcode = true,
			parser = function()
				return {}
			end, -- prevent crash
		}

		lint.linters_by_ft = {
			-- javascript = { "eslint_d" },
			-- typescript = { "eslint_d" },
			-- javascriptreact = { "eslint_d" },
			-- typescriptreact = { "eslint_d" },
			-- svelte = { "eslint_d" },
			-- go = { "golangci-lint" },
			sql = { "sqlfluff" },
			mysql = { "sqlfluff" },
			go = { "golangcilint" },
			python = { "pylint" },
			["_"] = {}, -- {revent fallback for unknown filetypes like Make
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		local debounce_timer = nil
		local debounce_delay = 500 -- in ms

		vim.api.nvim_create_autocmd("InsertLeave", {
			group = lint_augroup,
			callback = function()
				-- Cancel any existing timer
				if debounce_timer then
					pcall(function()
						debounce_timer:stop()
						debounce_timer:close()
					end)
					debounce_timer = nil
				end

				-- Create a new timer using vim.uv (new API)
				debounce_timer = vim.uv.new_timer()
				debounce_timer:start(
					debounce_delay,
					0,
					vim.schedule_wrap(function()
						require("lint").try_lint()
						-- Safe cleanup
						pcall(function()
							if debounce_timer then
								debounce_timer:close()
								debounce_timer = nil
							end
						end)
					end)
				)
			end,
		})

		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
