local edit = require("eddie.edit")
local Log = require("eddie").Log

---@class UserCmd
---@field create fun()
---@return UserCmd
local M = {}

local function create_cmd(command, f, opts)
	opts = opts or {}
	vim.api.nvim_create_user_command(command, f, opts)
end

function M.create()
	Log.trace("usercmd.create: creating user commands")
	create_cmd("Eddie", edit.open)
end

return M
