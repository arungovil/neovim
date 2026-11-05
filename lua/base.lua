local o = vim.opt

o.number = true
o.relativenumber = true
o.title = true
o.cursorline = true
o.wrap = false
o.scrolloff = 10
o.sidescrolloff = 8
o.signcolumn = "yes"
o.laststatus = 3
o.termguicolors = true
o.background = "dark"
o.winborder = "rounded"
o.pumblend = 5
o.pumheight = 10
o.fillchars = { eob = " ", diff = "╱" }
o.showcmd = true
o.shell = "bash"

-- Indent
o.expandtab = true
o.tabstop = 2
o.shiftwidth = 2
o.smartindent = true

-- Search
o.ignorecase = true
o.smartcase = true

-- Files / behaviour
o.undofile = true
o.updatetime = 250
o.splitright = true
o.splitbelow = true
o.completeopt = "menuone,noselect,popup"

-- Folding via treesitter, everything open by default
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel = 99

-- Floating cmdline and messages (experimental core API in 0.12)
require("vim._core.ui2").enable({})

vim.diagnostic.config({
	severity_sort = true,
	virtual_text = { spacing = 4, prefix = "●" },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "E",
			[vim.diagnostic.severity.WARN] = "W",
			[vim.diagnostic.severity.INFO] = "I",
			[vim.diagnostic.severity.HINT] = "H",
		},
	},
})

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Claude Code's fullscreen renderer uses the alternate screen, which has no scrollback in :terminal
vim.env.CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN = "1"
