return {
	"mfussenegger/nvim-lint",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- Pre-compute config path once at load time (avoid repeated stdpath calls)
		local sqlfluff_config = vim.fn.stdpath("config") .. "/.sqlfluff"

		-- Custom sqlfluff linter definition
		-- dialect removed from args: controlled by .sqlfluff config file per-project
		lint.linters.sqlfluff = {
			name = "sqlfluff",
			cmd = "sqlfluff",
			args = {
				"lint",
				"--config",
				sqlfluff_config,
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

		-- golangci-lint v2 custom definition
		-- v2 changed --out-format=json to --output.json.path=stdout.
		-- The built-in nvim-lint definition uses v1 flags and silently produces
		-- no diagnostics when v2 is installed (which Mason installs by default).
		lint.linters.golangci_lint_v2 = {
			name = "golangci_lint_v2",
			cmd = "golangci-lint",
			args = {
				"run",
				"--output.json.path=stdout",
				"--issues-exit-code=0",
				"--show-stats=false",
				-- Pass the directory of the current file as the target
				function()
					return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
				end,
			},
			stdin = false,
			stream = "stdout",
			ignore_exitcode = true,
			parser = require("lint.linters.golangcilint").parser,
		}

		lint.linters_by_ft = {
			-- Fast linters: run automatically on save and InsertLeave
			sql = { "sqlfluff" },
			mysql = { "sqlfluff" },
			python = { "pylint" },

			-- Slow linters: manual only via <leader>l
			-- golangci-lint removed from automatic triggers (5-30s run time).
			-- Use <leader>lg to lint Go files on demand.
			go = {},

			["_"] = {}, -- prevent fallback for unknown filetypes
		}

		-- Helper: only run try_lint() if the current filetype has linters configured.
		-- Avoids unnecessary overhead on filetypes with no linters.
		local function lint_if_configured()
			local ft = vim.bo.filetype
			local linters = lint.linters_by_ft[ft]
			if linters and #linters > 0 then
				lint.try_lint()
			end
		end

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		-- Lint after save only (BufReadPost removed: caused latency on file open
		-- before LSP had a chance to attach and render its own diagnostics first).
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = lint_augroup,
			callback = lint_if_configured,
		})

		-- Lint after leaving insert mode with a generous debounce.
		-- 500ms was too short for pylint (1-3s) and sqlfluff (2-5s).
		-- The debounce delays the *start* of the run, not the completion.
		vim.api.nvim_create_autocmd("InsertLeave", {
			group = lint_augroup,
			callback = function()
				vim.defer_fn(lint_if_configured, 1000)
			end,
		})

		-- Manual lint for current filetype (all configured linters)
		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })

		-- Manual Go lint with golangci-lint v2 (slow: run on demand only)
		vim.keymap.set("n", "<leader>lg", function()
			lint.try_lint("golangci_lint_v2")
		end, { desc = "Run golangci-lint on current Go file" })
	end,
}
