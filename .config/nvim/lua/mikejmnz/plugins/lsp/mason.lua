return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				-- "tsserver",
				"html",
				-- "htmx-lsp",
				-- "cssls",
				-- "tailwindcss",
				-- "svelte",
				"lua_ls",
				-- "graphql",
				-- "emmet_ls",
				-- "prismals",
				"templ",
				"gopls",
				"jqls",
				"pyright",
			},
			-- auto-install configured servers (with lspconfig)
			automatic_installation = true, -- not the same as ensure_installed
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				"isort", -- python formatter
				"black", -- python formatter
				"pylint", -- python linter
				-- "eslint_d", -- js linter
				"golangci-lint", -- go linter
				"gofumpt", -- go formatter
				"goimports", -- go formatter
				"gomodifytags", -- go formatter
				"jqls",
			},
		})
	end,
}
