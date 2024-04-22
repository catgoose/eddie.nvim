local cfg = require("eddie.core.config")

---@class eddie
---@field setup fun(opts: table)
---@field Log Logger
---@return eddie
local M = {}

function M.setup(opts)
	opts = opts or {}
	cfg.init(opts)
	M.Log = require("eddie.core.logger").init()
	require("eddie.usercmd").create()
end

return M
