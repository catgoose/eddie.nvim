---@class Utils
---@field deep_copy fun(orig: table): table
---@field string_format fun(msg: string, ...): string
---@return Utils
local M = {}

function M.deep_copy(orig)
	local t = type(orig)
	local copy
	if t == "table" then
		copy = {}
		for k, v in pairs(orig) do
			copy[k] = M.deep_copy(v)
		end
	else
		copy = orig
	end
	return copy
end

function M.string_format(msg, ...)
	local args = { ... }
	for i, v in ipairs(args) do
		if type(v) == "table" then
			args[i] = vim.inspect(v)
		end
	end
	return string.format(msg, unpack(args))
end

function M.split_string(str, sep, include_empty)
	sep = sep or " "
	include_empty = include_empty or false
	local t = {}
	local pattern = string.format("([^%s]*)", sep)
	for word in string.gmatch(str, pattern) do
		if include_empty or word ~= "" then
			table.insert(t, word)
		end
	end
	return t
end

function M.buf_lines(bufnr)
	if not bufnr then
		return
	end
	return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

function M.destroy_win(winnr)
	if vim.api.nvim_win_is_valid(winnr) then
		local bufnr = vim.api.nvim_win_get_buf(winnr)
		vim.api.nvim_win_close(winnr, true)
		if bufnr then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end
end

function M.write_buffer(bufnr)
	if not bufnr then
		return
	end
	if vim.api.nvim_buf_is_loaded(bufnr) then
		vim.api.nvim_buf_call(bufnr, function()
			vim.cmd("write")
		end)
	end
end

return M
