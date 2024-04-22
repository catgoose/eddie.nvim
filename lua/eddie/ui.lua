local Log = require("eddie").Log
local sf = require("eddie.core.utils").string_format
local get_opts = require("eddie.core.config").get_opts
local ac = require("eddie.autocmd")
local const = require("eddie.core.constants").get()
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
	local lines = opts.list

	local bufnr = vim.api.nvim_create_buf(false, true)
	local float_opts = get_opts().float
	local winnr = vim.api.nvim_open_win(bufnr, true, float_opts)

	vim.api.nvim_buf_set_lines(bufnr, 0, #lines, false, lines)
	vim.api.nvim_buf_set_name(bufnr, const.bo.filetype)

	for _, t in ipairs({ "bo", "wo" }) do
		for k, v in pairs(const[t]) do
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
