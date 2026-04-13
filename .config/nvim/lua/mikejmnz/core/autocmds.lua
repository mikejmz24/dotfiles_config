vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.treesitter.stop()
	end,
	desc = "Disable treesitter for markdown (nvim-treesitter 0.12 compat issue)",
})
