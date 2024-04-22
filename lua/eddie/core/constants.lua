local deep_copy = require("eddie.core.utils").deep_copy

local default_log_level = "warn"

---@class FloatOpts
---@field width number
---@field height number

---@class Opts
---@field log_level string

---@class Constants
---@field get_val fun(): Constants._val
---@return Constants
local M = {}
---@class Constants._val
---@field plugin_name string
---@field opts Opts
---@field default_log_level string
---@field log_levels string[]
---@field float FloatOpts
---@field float_defaults table
local _val = {
	plugin_name = "eddie",
	opts = {
		log_level = default_log_level,
		float = {
			height = 20,
			width = 30,
		},
		write_buffer = true,
	},
	default_log_level = default_log_level,
	log_levels = { "trace", "debug", "info", "warn", "error", "fatal" },
	float_defaults = {
		relative = "cursor",
		title = "Eddie",
		title_pos = "center",
		row = 0,
		col = 0,
		style = "minimal",
		border = "rounded",
	},
	bo = {
		buftype = "acwrite",
		filetype = "eddie",
		swapfile = false,
		buflisted = false,
		bufhidden = "delete",
		modified = false,
	},
	wo = {
		list = false,
		cursorline = true,
	},
	query = {
		class = [[
    (attribute
      (attribute_name) @attr_name
        (quoted_attribute_value (attribute_value) @properties)
        (#match? @attr_name "class")
    )
    ]],
		max = 3,
	},
}

M.get = function()
	return deep_copy(_val)
end

return M
