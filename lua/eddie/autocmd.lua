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
	local group = vim.api.nvim_create_augroup("EddieWrite", {})
	vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
		buffer = opts.bufnr,
		group = group,
		callback = opts.write_cb,
	})
end

return M
