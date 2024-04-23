local Log = require("eddie").Log
local sf = require("eddie.core.utils").string_format
local ts = require("eddie.treesitter")
local ui = require("eddie.ui")
local utils = require("eddie.core.utils")
local get_opts = require("eddie.core.config").get_opts

---@class Edit
---@field open fun()
---@return Edit
local M = {}

function M.open()
	local bufnr = vim.api.nvim_get_current_buf()
	local winid = vim.api.nvim_get_current_win()
	local cur = vim.api.nvim_win_get_cursor(winid)
	local ft = vim.bo.filetype
	Log.debug("edit.open: opening class list")
	local capture = ts.capture({
		bufnr = bufnr,
		cur = cur,
		filetype = ft,
	})
	if not capture then
		return
	end

	local write_cb = function(args)
		local cap = ts.capture({
			bufnr = bufnr,
			cur = cur,
			filetype = ft,
		})
		if not cap then
			return
		end
		local range = cap.range
		local lines = utils.buf_lines(args.buf)
		if not lines then
			return
		end

		Log.debug(sf(
			[[edit.open: got lines from popup:

lines: %s]],
			lines
		))
		if vim.bo[args.buf].modified then
			local new_lines = {}
			for _, line in ipairs(lines) do
				local words = utils.split_string(line)
				if #words > 0 then
					for _, word in ipairs(words) do
						table.insert(new_lines, word)
					end
				elseif #line > 0 then
					table.insert(new_lines, line)
				end
			end
			local lines_str = table.concat(new_lines, " ")
			vim.api.nvim_buf_set_text(bufnr, range.start_row, range.start_col, range.end_row, range.end_col, { lines_str })
			if get_opts().write_buffer then
				Log.debug(sf("writing buffer: %s", bufnr))
				utils.write_buffer(bufnr)
			end
		end
	end

	ui.create({
		list = capture.properties,
		write_cb = write_cb,
		cur = cur,
	})
end

return M
