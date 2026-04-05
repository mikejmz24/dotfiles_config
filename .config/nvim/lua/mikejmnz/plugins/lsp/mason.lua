return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")

		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		-- LSP servers (installed via mason-lspconfig)
		mason_lspconfig.setup({
			ensure_installed = {
				"html",
				"cssls",
				"lua_ls",
				"templ",
				"gopls",
				"jqls",
				"pyright",
				"sqls", -- was missing; configured in lspconfig.lua
				"texlab", -- was missing; configured in lspconfig.lua
			},
			-- automatic_installation removed: deprecated in mason-lspconfig v2
		})

		-- Formatters and linters (installed via mason-tool-installer)
		mason_tool_installer.setup({
			ensure_installed = {
				"prettier", -- formatter
				"stylua", -- lua formatter
				"isort", -- python import sorter
				"black", -- python formatter
				"pylint", -- python linter
				"golangci-lint", -- go meta-linter
				"gofumpt", -- go formatter
				"goimports", -- go import formatter
				"gomodifytags", -- go struct tag tool
				-- jqls removed: it's an LSP server, belongs in mason_lspconfig above
			},
		})
	end,
}
