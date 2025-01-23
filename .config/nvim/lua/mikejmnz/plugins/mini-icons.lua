-- lua/mikejmnz/plugins/mini-icons.lua
return {
	"echasnovski/mini.icons",
	version = false,
	config = function()
		require("mikejmnz.plugins.mini.icons").setup()
	end,
}
