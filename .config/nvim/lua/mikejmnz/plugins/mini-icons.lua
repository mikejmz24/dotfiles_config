return {
	"echasnovski/mini.icons",
	version = false,
	opts = {},
	init = function()
		-- Mock nvim-web-devicons so plugins that depend on it work with mini.icons
		package.preload["nvim-web-devicons"] = function()
			require("mini.icons").mock_nvim_web_devicons()
			return package.loaded["nvim-web-devicons"]
		end
	end,
}
