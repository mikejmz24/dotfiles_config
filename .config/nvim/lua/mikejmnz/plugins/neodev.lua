return {
	"folke/neodev.nvim",
	lazy = false, -- loads immediately (optional if you want it early)
	priority = 1000, -- high priority for correct setup before lua_ls
	config = function()
		require("neodev").setup({
			library = {
				enabled = true, -- enables runtime + plugin libraries
				runtime = true, -- runtime path (vim.uv, vim.loop, etc.)
				types = true, -- full signature help, docs and completion
				plugins = true, -- all installed plugins
			},
		})
	end,
}
