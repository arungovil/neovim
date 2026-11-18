-- Select the closest configuration to the file, not to Neovim's working directory.
local M = {}
-- Within a directory, prefer Oxfmt, then Biome, then Prettier.
local configs = {
	{ formatter = "oxfmt", names = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" } },
	{ formatter = "biome", names = { "biome.json", "biome.jsonc" } },
	{
		formatter = "prettier",
		names = {
			".prettierrc",
			".prettierrc.json",
			".prettierrc.yaml",
			".prettierrc.yml",
			".prettierrc.json5",
			".prettierrc.js",
			".prettierrc.cjs",
			".prettierrc.mjs",
			".prettierrc.toml",
			".prettierrc.ts",
			".prettierrc.cts",
			".prettierrc.mts",
			"prettier.config.js",
			"prettier.config.cjs",
			"prettier.config.mjs",
			"prettier.config.ts",
			"prettier.config.cts",
			"prettier.config.mts",
		},
	},
}

local function package_has_prettier(dir)
	local ok, lines = pcall(vim.fn.readfile, dir .. "/package.json")
	if not ok then
		return false
	end
	local parsed, package = pcall(vim.json.decode, table.concat(lines, "\n"))
	return parsed and type(package) == "table" and package.prettier ~= nil
end

function M.select(bufnr)
	local filename = vim.api.nvim_buf_get_name(bufnr)
	if filename == "" then
		return nil
	end
	local dir = vim.fs.dirname(vim.fs.normalize(filename))
	while dir do
		for _, config in ipairs(configs) do
			for _, name in ipairs(config.names) do
				local stat = vim.uv.fs_stat(dir .. "/" .. name)
				if stat and stat.type == "file" then
					return config.formatter, dir
				end
			end
		end
		if package_has_prettier(dir) then
			return "prettier", dir
		end
		local parent = vim.fs.dirname(dir)
		if parent == dir then
			break
		end
		dir = parent
	end
end

function M.formatters(bufnr)
	local formatter = M.select(bufnr)
	if formatter then
		-- A missing configured executable must not trigger LSP or another formatter.
		return { formatter, lsp_format = "never" }
	end
	return { lsp_format = "fallback" }
end

-- Only use Prettier for these filetypes; Biome and Oxfmt stay JS/TS-only.
function M.prettier_formatters(bufnr)
	if M.select(bufnr) == "prettier" then
		return { "prettier", lsp_format = "never" }
	end
	return { lsp_format = "fallback" }
end

function M.cwd(_, ctx)
	local _, dir = M.select(ctx.buf)
	return dir
end

return M
