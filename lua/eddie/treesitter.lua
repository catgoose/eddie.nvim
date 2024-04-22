local Log = require("eddie").Log
local sf = require("eddie.core.utils").string_format
local const = require("eddie.core.constants").get()
local utils = require("eddie.core.utils")

---@class Range
---@field start_row number
---@field start_col number
---@field end_row number
---@field end_col number

---@class CaptureOpts
---@field bufnr number
---@field cur number[]
---@field filetype string

---@class Capture
---@field properties string[]
---@field range Range

---@class Treesitter
---@field capture fun(opts: CaptureOpts): Capture
---@return Treesitter
local M = {}

local warn = false

local function get_capture(ts, opts)
	local ok, query = pcall(vim.treesitter.query.parse, opts.filetype, const.query.class)
	if not ok or not query then
		if warn then
			Log.warn("treesitter.capture: no query found")
		end
		return
	end

	Log.trace(sf(
		[[treesitter.capture: found query:

%s
  ]],
		query
	))
	for id, node in query:iter_captures(ts, opts.bufnr, 0, -1) do
		local name = query.captures[id]
		Log.trace(sf("captures: %s", query.captures))
		Log.trace(sf("capture name found: %s", name))
		if name == "properties" then
			local properties = vim.treesitter.get_node_text(node, opts.bufnr)
			local range = { vim.treesitter.get_node_range(node) }
			if not properties or not range then
				if warn then
					Log.warn("treesitter.capture: no properties or range found")
					return
				end
			end
			local capture = {
				properties = utils.split_string(properties),
				range = {
					start_row = range[1],
					start_col = range[2],
					end_row = range[3],
					end_col = range[4],
				},
			}
			Log.debug(sf(
				[[edit.open: found capture:
        capture: %s
        ]],
				capture
			))
			return capture
		end
	end
	return nil
end

--  TODO: 2024-04-20 - JXS Parser
function M.capture(opts)
	opts = opts or {}
	opts.bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
	opts.cur = opts.cur or vim.api.nvim_win_get_cursor(0)
	opts.filetype = opts.filetype or vim.bo.filetype

	local ok, cursor = pcall(vim.treesitter.get_node, {
		bufnr = opts.bufnr,
		ignore_injections = false,
		pos = opts.cur,
	})
	if not ok or not cursor then
		if warn then
			Log.warn("treesitter.capture: no cursor found")
		end
		return
	end

	local max = const.query.max
	while cursor do
		if max < 0 then
			break
		end
		local capture = get_capture(cursor, opts)
		if capture then
			return capture
		end
		cursor = cursor:parent()
		if not cursor then
			break
		end
		max = max - 1
	end

	if warn then
		Log.warn(sf(
			[[treesitter.capture: no properties found:

opts: %s
  ]],
			opts
		))
	end
end

return M
