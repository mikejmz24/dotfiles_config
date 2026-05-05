return {
	"stevearc/oil.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local oil = require("oil")
		oil.setup({
			view_options = {
				show_hidden = true,
			},
			float = {
				padding = 2,
				border = "rounded",
				win_options = {
					winblend = 0, -- set to 0 to prevent transparency bleed
				},
			},
		})

		vim.keymap.set("n", "-", oil.toggle_float, { desc = "Toggle parent directory" })
	end,
}
