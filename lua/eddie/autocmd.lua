local Log = require("eddie").Log
local sf = require("eddie.core.utils").string_format

---@class Autocmd
---@field set fun(opts: WindowOpt)
---@return Autocmd
local M = {}

function M.set(opts)
	if not opts or not opts.bufnr or not opts.write_cb then
		Log.warn(sf(
			[[autocmd: set invalid opts

      opts: %s
      ]],
			opts
		))
		return
	end
	local write_group = vim.api.nvim_create_augroup("EddieWrite", {})
	vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
		buffer = opts.bufnr,
		group = write_group,
		callback = opts.write_cb,
	})
	local change_group = vim.api.nvim_create_augroup("EddieTextChanged", {})
	vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "InsertChange", "InsertCharPre" }, {
		buffer = opts.bufnr,
		group = change_group,
		callback = function()
			local contents = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
			local max_width = 0
			for _, line in ipairs(contents) do
				if #line > max_width then
					max_width = #line
				end
			end

			local config = require("eddie.core.config").get_opts()
			local win = config.window
			local function tens(num)
				local count = 0
				while num >= 1 do
					num = num / 10
					count = count + 1
				end
				return count - 1
			end
			vim.api.nvim_win_set_config(opts.winnr, {
				height = #contents > win.min_height and #contents + win.padding.height or win.min_height,
				width = max_width > win.min_width and max_width + win.padding.width + tens(#contents) + 1 or win.min_width,
			})
		end,
	})
end

return M
