local Log = require("eddie").Log
local sf = require("eddie.core.utils").string_format
local get_opts = require("eddie.core.config").get_opts
local ac = require("eddie.autocmd")
local utils = require("eddie.core.utils")

---@class WindowOpt
---@field list table
---@field write_cb fun(args: table)
---@field cur number[]
---@field bufnur number
---@field winnr number

---@class UI
---@field create fun(opts: WindowOpt)
---@return UI
local M = {}

function M.create(opts)
	if not opts or not opts.list or not opts.write_cb or not opts.cur then
		Log.warn(sf(
			[[ui: create invalid opts

    opts: %s
    ]],
			opts
		))
		return
	end
	opts.config = get_opts()

	opts.bufnr = vim.api.nvim_create_buf(false, true)
	opts.winnr = vim.api.nvim_open_win(opts.bufnr, true, opts.config.float)

	vim.api.nvim_buf_set_lines(opts.bufnr, 0, #opts.list, false, opts.list)
	vim.api.nvim_buf_set_name(opts.bufnr, opts.config.bo.filetype)

	for _, t in ipairs({ "bo", "wo" }) do
		for k, v in pairs(opts.config[t]) do
			vim[t][t == "bo" and opts.bufnr or t == "wo" and opts.winnr or nil][k] = v
		end
	end

	ac.set(opts)

	vim.keymap.set("n", "q", function()
		opts.write_cb({ buf = opts.bufnr })
		utils.destroy_win(opts)
	end, { buffer = opts.bufnr, silent = true })

	return opts
end

return M
