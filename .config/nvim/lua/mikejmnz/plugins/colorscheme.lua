return {
	"folke/tokyonight.nvim",
	priority = 1000,
	config = function()
		local bg_highlight = "#143652"
		local bg_search = "#0A64AC"
		local bg_visual = "#275378"

		require("tokyonight").setup({
			style = "night",
			on_colors = function(colors)
				colors.bg_highlight = bg_highlight
				colors.bg_search = bg_search
				colors.bg_visual = bg_visual
			end,
		})

		vim.cmd.colorscheme("tokyonight")
	end,
}
