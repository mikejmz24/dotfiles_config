-- NOTE: templ LSP must be installed manually via Go, not Mason:
--   go install github.com/a-h/templ/cmd/templ@latest
-- Ensure `templ` is on your PATH (add ~/go/bin to PATH if needed)

return {
	"williamboman/mason.nvim",
	dependencies = {
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		require("mason").setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		require("mason-tool-installer").setup({
			ensure_installed = {
				-- LSP servers
				-- NOTE: Mason package names use dashes, NOT lspconfig server names
				"html-lsp", -- lspconfig: html
				"css-lsp", -- lspconfig: cssls
				"lua-language-server", -- lspconfig: lua_ls
				"htmx-lsp", -- lspconfig: htmx (was missing)
				"gopls", -- lspconfig: gopls
				"jq-lsp", -- lspconfig: jqls (was wrong: "jqls")
				"pyright", -- lspconfig: pyright
				"sqls", -- lspconfig: sqls
				"texlab", -- lspconfig: texlab
				-- "templ" is NOT in Mason registry — install via:
				--   go install github.com/a-h/templ/cmd/templ@latest

				-- Formatters
				"prettier",
				"stylua",
				"isort",
				"black",
				"gofumpt",
				"goimports",
				"gomodifytags",
				"sqlfluff",

				-- Linters
				"golangci-lint",
				"pylint",
			},
		})
	end,
}
