local const = require("eddie.core.constants").get()
local utils = require("eddie.core.utils")
local sf = utils.string_format

---@class Config
---@field get_opts fun(): Opts
---@field init fun(opts: Opts): Opts
---@return Config
local M = {}

local _opts = const.opts

function M.get_opts()
	return utils.deep_copy(_opts)
end

local function set_local_opts(opts)
	_opts.log_level = vim.tbl_contains(const.log_levels, opts.log_level) and opts.log_level or const.default_log_level
	_opts = vim.tbl_deep_extend("keep", opts, _opts)
end

local function set_opts_defaults(opts)
	local float_opts = vim.tbl_deep_extend("keep", const.opts.float, const.float_defaults)
	opts.float = float_opts
	return opts
end

function M.init(opts)
	opts = opts or {}
	opts = set_opts_defaults(opts)
	set_local_opts(opts)
	return M.get_opts()
end

return M
