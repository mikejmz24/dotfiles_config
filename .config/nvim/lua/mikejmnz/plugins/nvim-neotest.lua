return {
	"nvim-neotest/neotest",

	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		-- "nvim-lua/plenary.nvim",
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/neotest-python",
		-- "nvim-neotest/neotest-plenary",
		-- "nvim-neotest/neotest-vim-test",
		-- "mohammad5305/pytest.nvim",
	},
	config = function()
		local neotest = require("neotest")
		neotest.setup({
			adapters = {
				require("neotest-python")({
					-- dap = { justMyCode = false },
					runner = "pytest",
					pytest_discover_instances = true,
				}),
				-- 	require("neotest-plenary"),
				-- 	require("neotest-vim-test")({
				-- 		ignore_file_types = { "python", "vim", "lua" },
				-- 	},
			},
		})

		-- Run the nearest test (Test current)
		vim.keymap.set("n", "<leader>tc", function()
			neotest.run.run()
		end, { desc = "Run current test" })

		-- Run the current file (Test current file)
		vim.keymap.set("n", "<leader>tC", function()
			neotest.run.run(vim.fn.expand("%"))
		end, { desc = "Run current file" })
	end,
}
