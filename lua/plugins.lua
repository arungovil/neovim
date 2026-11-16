-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key before loading plugins
vim.g.mapleader = ";"

require("lazy").setup({
	defaults = { lazy = true },
	performance = {
		rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
	},

	-- Color scheme
	{
		"Aejkatappaja/cendre",
		lazy = false,
		priority = 1000,
		opts = { background = "hard", italic_virtual_text = false },
		config = function(_, opts)
			require("cendre").setup(opts)
			vim.cmd.colorscheme("cendre")
		end,
	},

	-- Clojure
	{ "Olical/conjure", ft = { "clojure", "fennel" } },
	{ "gpanders/nvim-parinfer", ft = { "clojure", "fennel", "lisp", "scheme" } },
	{ "HiPhish/rainbow-delimiters.nvim", event = "VeryLazy" },

	-- Status line
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		opts = {
			options = {
				icons_enabled = false,
				globalstatus = true,
				theme = "cendre",
				component_separators = "▏",
				section_separators = "",
			},
		},
	},

	-- Git
	{
		"NeogitOrg/neogit",
		cmd = "Neogit",
		dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
		opts = {},
	},
	{ "lewis6991/gitsigns.nvim", event = { "BufReadPre", "BufNewFile" }, opts = {} },
	{
		"pwntester/octo.nvim",
		cmd = "Octo",
		dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
		opts = {
			picker = "snacks",
			suppress_missing_scope = { projects_v2 = true },
			default_to_projects_v2 = true,
		},
	},

	-- Editor
	{ "nvim-mini/mini.pairs", event = "InsertEnter", opts = {} },
	{ "windwp/nvim-ts-autotag", event = { "BufReadPre", "BufNewFile" }, opts = {} },
	{ "NvChad/nvim-colorizer.lua", event = { "BufReadPre", "BufNewFile" }, opts = { filetypes = { "*" } } },
	{ "numToStr/Comment.nvim", keys = { "gc", "gb", { "gc", mode = "v" } }, opts = {} },
	{ "kylechui/nvim-surround", event = "VeryLazy", opts = {} },

	-- Treesitter (main branch: parsers compiled with the tree-sitter CLI)
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install({
				"javascript",
				"typescript",
				"tsx",
				"jsdoc",
				"go",
				"gomod",
				"python",
				"clojure",
				"css",
				"html",
				"c",
				"cpp",
				"lua",
				"vim",
				"vimdoc",
				"json",
				"yaml",
				"toml",
				"markdown",
				"markdown_inline",
				"bash",
				"regex",
				"diff",
			})
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(ev)
					if pcall(vim.treesitter.start, ev.buf) then
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},

	-- Picker, indent guides, notifications, word highlight, lazygit-free utilities
	{
		"folke/snacks.nvim",
		lazy = false,
		priority = 900,
		opts = {
			picker = {
				sources = { files = { hidden = true }, grep = { hidden = true } },
				icons = {
					files = { enabled = false },
					git = { enabled = false },
					diagnostics = { Error = "E", Warn = "W", Hint = "H", Info = "I" },
				},
			},
			indent = { enabled = true },
			notifier = { enabled = true },
			words = { enabled = true },
			input = { enabled = true },
		},
	},

	-- Sidebar file tree
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
		keys = {
			{ "<leader>d", "<cmd>Neotree toggle reveal position=right<cr>", desc = "File tree (sidebar)" },
		},
		opts = {
			filesystem = {
				filtered_items = { visible = true },
				follow_current_file = { enabled = true },
				hijack_netrw_behavior = "disabled", -- leave directory buffers to oil
			},
			window = { width = 40 },
		},
	},

	-- File explorer (edit the filesystem like a buffer)
	{
		"stevearc/oil.nvim",
		cmd = "Oil",
		opts = {
			default_file_explorer = true,
			columns = {},
			view_options = { show_hidden = true },
			float = { max_width = 90, max_height = 28 },
			keymaps = { ["q"] = { "actions.close", mode = "n" }, ["h"] = { "actions.parent", mode = "n" } },
		},
	},

	-- Formatting
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>F",
				function()
					require("conform").format({ lsp_format = "fallback", timeout_ms = 1000 })
				end,
				mode = { "n", "v" },
				desc = "Format file or range",
			},
		},
		opts = {
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				markdown = { "prettier" },
				yaml = { "yamlfmt" },
				lua = { "stylua" },
				python = { "ruff_format" },
				c = { "clang-format" },
				cpp = { "clang-format" },
			},
			-- go (gopls) and clojure (clojure-lsp) format through the LSP fallback
			format_on_save = { lsp_format = "fallback", timeout_ms = 1000 },
		},
	},

	-- LSP: nvim-lspconfig only supplies the default server configs (lsp/*.lua)
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})
			vim.lsp.enable({
				"vtsls",
				"html",
				"cssls",
				"gopls",
				"clangd",
				"clojure_lsp",
				"basedpyright",
				"ruff",
				"lua_ls",
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(ev)
					local function map(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
					end
					map("<leader>R", "<cmd>LspRestart<CR>", "Restart LSP")
					map("<leader>[", function()
						vim.diagnostic.jump({ count = -1 })
					end, "Previous diagnostic")
					map("<leader>]", function()
						vim.diagnostic.jump({ count = 1 })
					end, "Next diagnostic")
					map("<leader>;", vim.lsp.buf.hover, "Show documentation")
					map("<leader>'", function()
						Snacks.picker.lsp_references()
					end, "LSP references")
					map("gd", vim.lsp.buf.definition, "Go to definition")
				end,
			})
		end,
	},

	-- Completion
	{
		"saghen/blink.cmp",
		version = "1.*",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = { "rafamadriz/friendly-snippets" },
		opts = {
			keymap = {
				preset = "enter",
				["<C-k>"] = { "select_prev", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },
			},
			completion = {
				list = { selection = { preselect = false } },
				documentation = { auto_show = true, auto_show_delay_ms = 200 },
				menu = { draw = { columns = { { "label", "label_description", gap = 1 }, { "kind" } } } },
			},
			cmdline = { enabled = true },
		},
	},

	-- LSP/tool installer (package names are Mason's, not lspconfig's)
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		lazy = false,
		dependencies = { "mason-org/mason.nvim" },
		config = function()
			require("mason").setup({
				ui = { icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" } },
			})
			require("mason-tool-installer").setup({
				ensure_installed = {
					"vtsls",
					"html-lsp",
					"css-lsp",
					"gopls",
					"clangd",
					"clojure-lsp",
					"basedpyright",
					"ruff",
					"lua-language-server",
					"prettier",
					"stylua",
					"clang-format",
					"yamlfmt",
				},
			})
		end,
	},
}, { change_detection = { notify = false } })
