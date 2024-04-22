local Log = require("eddie").Log
local sf = require("eddie.core.utils").string_format
local get_opts = require("eddie.core.config").get_opts
local ac = require("eddie.autocmd")
local utils = require("eddie.core.utils")

---@class UI
---@field create fun(opts: table)
---@return UI
local M = {}

function M.create(opts)
	if not opts or not opts.list or not opts.write_cb then
		Log.warn(sf(
			[[ui: create invalid opts

    opts: %s
    ]],
			opts
		))
		return
	end
	opts.config = get_opts()

	local bufnr = vim.api.nvim_create_buf(false, true)
	local winnr = vim.api.nvim_open_win(bufnr, true, opts.config.float)

	vim.api.nvim_buf_set_lines(bufnr, 0, #opts.list, false, opts.list)
	vim.api.nvim_buf_set_name(bufnr, opts.config.bo.filetype)

	for _, t in ipairs({ "bo", "wo" }) do
		for k, v in pairs(opts.config[t]) do
			vim[t][t == "bo" and bufnr or t == "wo" and winnr or nil][k] = v
		end
	end

	ac.set({
		bufnr = bufnr,
		write_cb = opts.write_cb,
	})

	vim.keymap.set("n", "q", function()
		opts.write_cb({
			buf = bufnr,
		})
		utils.destroy_win(winnr)
	end, { buffer = bufnr, silent = true })

	return {
		bufnr = bufnr,
		winnr = winnr,
	}
end

return M
