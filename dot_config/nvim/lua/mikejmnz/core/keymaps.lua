-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("n", "<leader>nh", vim.cmd.nohl, { desc = "Clear search highlights" })

-- Window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Resize splits with Alt keys (preserves <C-h/j/k/l> for split navigation)
keymap.set("n", "<A-l>", "<C-W><", { desc = "Resize split left" })
keymap.set("n", "<A-h>", "<C-W>>", { desc = "Resize split right" })
keymap.set("n", "<A-k>", "<C-W>+", { desc = "Resize split up" })
keymap.set("n", "<A-j>", "<C-W>-", { desc = "Resize split down" })

-- Buffer navigation
keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Diagnostic navigation
-- NOTE: [d and ]d are defined here globally; do NOT redefine them in lspconfig on_attach.
-- float = true opens the diagnostic float automatically on jump, removing need for a
-- separate keymap just to view the message.
keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic" })

keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next diagnostic" })

-- Show diagnostic float for current cursor position
-- NOTE: <leader>d is intentionally NOT defined here — it lives in lspconfig on_attach
-- as a buffer-local mapping so it only activates when an LSP is attached.
keymap.set("n", "<leader>e", function()
	vim.diagnostic.open_float({ border = "rounded", scope = "cursor" })
end, { desc = "Show diagnostic float" })

keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic quickfix list" })

-- ── Diagnostics helpers (defined once at module load) ────────────────────────

local SEVERITY_MAP = {
	[vim.diagnostic.severity.ERROR] = "E",
	[vim.diagnostic.severity.WARN] = "W",
	[vim.diagnostic.severity.INFO] = "I",
	[vim.diagnostic.severity.HINT] = "H",
}

--- Returns a display-friendly file name relative to the project root.
--- Falls back to "[No Name]" for unnamed buffers, or the absolute path
--- when the file lives outside the current working directory.
local function fmt_fname(raw, project)
	if raw == "" then
		return "[No Name]"
	end
	local rel = vim.fn.fnamemodify(raw, ":.")
	-- fnamemodify returns the original string unchanged when it cannot produce
	-- a shorter relative path (i.e. the file is outside cwd).
	return (rel ~= raw) and (".../" .. project .. "/" .. rel) or raw
end

--- Core: sorts `diags`, formats them, yanks to `+` register, and notifies.
--- `resolve_fname(d)` receives a diagnostic and returns its display path.
local function yank_diagnostics(diags, resolve_fname, empty_msg)
	if #diags == 0 then
		vim.notify(empty_msg, vim.log.levels.WARN)
		return
	end

	table.sort(diags, function(a, b)
		return a.severity < b.severity
	end)

	local project = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

	local lines = vim.tbl_map(function(d)
		return string.format(
			"%s:%d:%d: [%s] %s",
			resolve_fname(d, project),
			d.lnum + 1,
			d.col + 1,
			SEVERITY_MAP[d.severity] or "?",
			d.message
		)
	end, diags)

	vim.fn.setreg("+", table.concat(lines, "\n"))
	vim.notify(("Diagnostics copied to clipboard (%d items)"):format(#lines), vim.log.levels.INFO)
end

-- ── Keymaps ───────────────────────────────────────────────────────────────────

-- Yank ALL diagnostics (all open buffers) to clipboard.
keymap.set("n", "<leader>yd", function()
	local diags = vim.diagnostic.get()

	-- Cache buf→display-name so nvim_buf_get_name isn't called once per
	-- diagnostic when many entries share the same buffer.
	local fname_cache = {}

	yank_diagnostics(diags, function(d, project)
		if not fname_cache[d.bufnr] then
			fname_cache[d.bufnr] = fmt_fname(vim.api.nvim_buf_get_name(d.bufnr), project)
		end
		return fname_cache[d.bufnr]
	end, "No diagnostics to copy")
end, { desc = "Yank all diagnostics to clipboard" })

-- Yank CURRENT BUFFER diagnostics to clipboard.
keymap.set("n", "<leader>ybd", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local diags = vim.diagnostic.get(bufnr)

	-- Resolve the name once; every diagnostic in this buffer shares the same file.
	local resolved_fname -- lazily set inside resolve_fname on first call

	yank_diagnostics(diags, function(_, project)
		if not resolved_fname then
			resolved_fname = fmt_fname(vim.api.nvim_buf_get_name(bufnr), project)
		end
		return resolved_fname
	end, "No diagnostics in current buffer")
end, { desc = "Yank current buffer diagnostics to clipboard" })

-- LSP restart
-- NOTE: :LspRestart is the legacy alias (Nvim 0.11 and older).
-- On Nvim 0.12+, the correct command is :lsp restart (native API).
-- Also update <leader>rs in lspconfig.lua on_attach to use "<cmd>lsp restart<CR>".
keymap.set("n", "<leader>lR", "<cmd>lsp restart<CR>", { desc = "Restart LSP" })

-- Better paste in visual mode (keeps register)
-- P in Neovim 0.10+ does not clobber the unnamed register in visual mode.
keymap.set("x", "p", "P", { desc = "Paste without yanking" })

-- Move lines up/down in visual mode.
-- NOTE: uses : (not <cmd>) intentionally — <cmd> does not preserve '< '> marks
-- needed by :m to move relative to the visual selection.
-- J is intentionally overridden here (visual join is rarely useful vs. line moving).
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })

-- Better indenting in visual mode (reselects after indent so you can repeat)
keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })
keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
