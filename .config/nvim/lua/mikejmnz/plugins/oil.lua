return {
	"stevearc/oil.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local oil = require("oil")
		oil.setup()
		vim.keymap.set("n", "-", function()
			oil.toggle_float()
		end, { desc = "Toggle parent directory" })
	end,
}
