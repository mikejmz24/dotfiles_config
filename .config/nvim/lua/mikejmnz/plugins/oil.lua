return {
	"stevearc/oil.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local oil = require("oil")
		oil.setup({
			view_options = {
				show_hidden = true, -- always show hidden files
			},
		})

		vim.keymap.set("n", "-", function()
			oil.toggle_float()
		end, { desc = "Toggle parent directory" })
	end,
}
