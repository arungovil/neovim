-- Platform-specific bits so the same config works on macOS and Linux.
local M = {}

local sysname = vim.uv.os_uname().sysname
if sysname == "Darwin" then
	M.os = "mac"
elseif sysname == "Linux" then
	M.os = "linux"
else
	M.os = sysname:lower()
end

local function exists(path)
	return path ~= nil and path ~= "" and vim.fn.executable(path) == 1
end

-- $SHELL wins when it actually exists, otherwise fall back to the platform default.
M.shell = (function()
	local candidates = { vim.env.SHELL }
	local fallbacks = M.os == "mac" and { "/bin/zsh", "/bin/bash", "/bin/sh" }
		or { "/bin/bash", "/bin/sh", "/bin/zsh" }
	vim.list_extend(candidates, fallbacks)
	for _, shell in ipairs(candidates) do
		if exists(shell) then
			return shell
		end
	end
	return "/bin/sh"
end)()

-- Absolute path of an executable on PATH, or "" when it is missing.
function M.executable(name)
	return vim.fn.exepath(name)
end

return M
