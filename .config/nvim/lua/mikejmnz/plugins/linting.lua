return {
	"mfussenegger/nvim-lint",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		local api = vim.api
		local fn = vim.fn
		local uv = vim.uv or vim.loop
		local diag_severity = vim.diagnostic.severity

		-- Pre-compute config path once at load time
		local sqlfluff_config = fn.stdpath("config") .. "/.sqlfluff"

		-- Cache resolved pylint command per project root
		local pylint_cmd_cache = {}

		local sqlfluff_severity_map = {
			warning = diag_severity.WARN,
			error = diag_severity.ERROR,
		}

		local function resolve_pylint_cmd()
			local root = vim.fs.root(0, { "pyproject.toml", "setup.py", ".venv" })
			if not root then
				return "pylint"
			end

			local cached = pylint_cmd_cache[root]
			if cached then
				return cached
			end

			local venv_pylint = root .. "/.venv/bin/pylint"
			local venv_python = root .. "/.venv/bin/python"

			local cmd
			if fn.executable(venv_pylint) == 1 and fn.executable(venv_python) == 1 then
				cmd = venv_pylint
			else
				cmd = "pylint"
			end

			pylint_cmd_cache[root] = cmd
			return cmd
		end

		-- nvim-lint supports function-valued cmd at runtime, but some Lua LS
		-- typings declare cmd as string only.
		if lint.linters.pylint then
			---@diagnostic disable-next-line: assign-type-mismatch
			lint.linters.pylint.cmd = resolve_pylint_cmd
		end

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
				if not output or output == "" then
					return {}
				end

				local ok, decoded = pcall(vim.json.decode, output)
				if not (ok and decoded and decoded[1] and decoded[1].violations) then
					return {}
				end

				local diagnostics = {}
				for _, v in ipairs(decoded[1].violations) do
					if v.start_line_no and v.start_line_pos then
						diagnostics[#diagnostics + 1] = {
							lnum = v.start_line_no - 1,
							col = v.start_line_pos - 1,
							end_lnum = v.end_line_no and (v.end_line_no - 1) or nil,
							end_col = v.end_line_pos and (v.end_line_pos - 1) or nil,
							message = string.format("[%s] %s", v.code, v.description),
							severity = sqlfluff_severity_map[v.severity] or diag_severity.WARN,
							source = "sqlfluff",
						}
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
					return fn.fnamemodify(api.nvim_buf_get_name(0), ":h")
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

		-- Only run try_lint() if the current filetype has linters configured.
		local function lint_if_configured(bufnr)
			bufnr = bufnr or api.nvim_get_current_buf()
			local ft = vim.bo[bufnr].filetype
			local linters = lint.linters_by_ft[ft]
			if linters and #linters > 0 then
				lint.try_lint()
			end
		end

		local lint_augroup = api.nvim_create_augroup("lint", { clear = true })

		-- Lint after save only
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = lint_augroup,
			callback = function(args)
				lint_if_configured(args.buf)
			end,
		})

		-- Lint after leaving insert mode with a single timer per buffer.
		-- This avoids stacking multiple deferred callbacks if InsertLeave fires
		-- repeatedly within the debounce window.
		local insertleave_timers = {}

		vim.api.nvim_create_autocmd("InsertLeave", {
			group = lint_augroup,
			callback = function(args)
				local bufnr = args.buf
				local old_timer = insertleave_timers[bufnr]

				if old_timer then
					old_timer:stop()
					if not old_timer:is_closing() then
						old_timer:close()
					end
				end

				local new_timer = assert(uv.new_timer())
				insertleave_timers[bufnr] = new_timer

				new_timer:start(
					1000,
					0,
					vim.schedule_wrap(function()
						if not new_timer:is_closing() then
							new_timer:close()
						end
						insertleave_timers[bufnr] = nil

						if api.nvim_buf_is_valid(bufnr) then
							lint_if_configured(bufnr)
						end
					end)
				)
			end,
		})

		vim.api.nvim_create_autocmd("BufWipeout", {
			group = lint_augroup,
			callback = function(args)
				local timer = insertleave_timers[args.buf]
				if timer then
					timer:stop()
					if not timer:is_closing() then
						timer:close()
					end
					insertleave_timers[args.buf] = nil
				end
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
