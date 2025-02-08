return {
	"nvim-lua/plenary.nvim", -- Keep your existing dependency

	-- Mini.icons
	{
		"echasnovski/mini.icons",
		version = false,
		config = function()
			require("mikejmnz.plugins.mini.icons").setup()
		end,
	},

	-- Add your other plugins that have configuration files
	require("mikejmnz.plugins.colorscheme"),
	require("mikejmnz.plugins.comment"),
	require("mikejmnz.plugins.formatting"),
	require("mikejmnz.plugins.linting"),
	require("mikejmnz.plugins.lsp.lspconfig"),
	require("mikejmnz.plugins.lsp.mason"),
	require("mikejmnz.plugins.lsp.none-ls"),
	require("mikejmnz.plugins.lualine"),
	require("mikejmnz.plugins.nvim-autopairs"),
	require("mikejmnz.plugins.nvim-cmp"),
	require("mikejmnz.plugins.nvim-treesitter"),
	require("mikejmnz.plugins.nvim-treesitter-text-objects"),
	require("mikejmnz.plugins.nvim-web-devicons"),
	require("mikejmnz.plugins.oil"),
	require("mikejmnz.plugins.surround"),
	require("mikejmnz.plugins.telescope"),
	require("mikejmnz.plugins.todo-comments"),
	require("mikejmnz.plugins.trouble"),
	require("mikejmnz.plugins.which-key"),
}
