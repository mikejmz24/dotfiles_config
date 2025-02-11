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
        "--dialect", "mysql",
        "--config", "/Users/miguel.jimenez2/.dotfiles/.config/nvim/.sqlfluff", -- Explicitly set the config path
        "--format", "json",
        "-"                                                                    -- Read from stdin
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
                  source = "sqlfluff"
                })
              end
            end
          end
        end
        return diagnostics
      end
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
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })


    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
