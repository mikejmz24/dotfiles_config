return {
	"echasnovski/mini.icons",
	version = false,
	opts = {
		filetype = {
			graphql = { glyph = "", hl = "MiniIconsRed" },
		},
		extension = {
			gql = { glyph = "", hl = "MiniIconsRed" },
			graphql = { glyph = "", hl = "MiniIconsRed" },
		},
	},
	init = function()
		package.preload["nvim-web-devicons"] = function()
			require("mini.icons").mock_nvim_web_devicons()
			return package.loaded["nvim-web-devicons"]
		end
	end,
}
