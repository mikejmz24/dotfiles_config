vim.env.PATH = "/opt/homebrew/bin:" .. vim.env.PATH

require("mikejmnz.core")

vim.filetype.add({
	extension = {
		templ = "templ",
	},
})

require("mikejmnz.lazy")
