--=======================================
--| FLOATING TERMINAL (tt, tk, tq, esc) |
--=======================================

local M = {}

local state = {
	buf = nil,
	win = nil,
	is_open = false,
	job_id = nil,
	augroup = vim.api.nvim_create_augroup("FloatingTerminal", { clear = true }),
}

local function create_buffer()
	if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
		return state.buf
	end

	state.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[state.buf].bufhidden = "hide"
	return state.buf
end

local function get_window_config()
	local width = math.floor(vim.o.columns * 0.6)
	local height = math.floor(vim.o.lines * 0.5)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	return {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	}
end

local function apply_highlights(win)
	vim.api.nvim_set_hl(0, "FloatingTermNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "FloatingTermBorder", { bg = "none" })

	if win and vim.api.nvim_win_is_valid(win) then
		vim.wo[win].winblend = 0
		vim.wo[win].winhighlight = "Normal:FloatingTermNormal,"
			.. "NormalFloat:FloatingTermNormal,"
			.. "EndOfBuffer:FloatingTermNormal,"
			.. "FloatBorder:FloatingTermBorder"
	end
end

local function cleanup_dead_terminal(buf)
	if buf and vim.api.nvim_buf_is_valid(buf) then
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(buf) then
				pcall(vim.api.nvim_buf_delete, buf, { force = true })
			end
		end)
	end
end

local function ensure_terminal()
	if state.job_id and state.buf and vim.api.nvim_buf_is_valid(state.buf) then
		return
	end

	if state.buf and vim.api.nvim_buf_is_valid(state.buf) and not state.job_id then
		pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
		state.buf = nil
	end

	local buf = create_buffer()

	vim.api.nvim_buf_call(buf, function()
		state.job_id = vim.fn.termopen(vim.o.shell)
	end)

	vim.api.nvim_clear_autocmds({
		group = state.augroup,
		buffer = buf,
		event = "TermClose",
	})

	vim.api.nvim_create_autocmd("TermClose", {
		group = state.augroup,
		buffer = buf,
		once = true,
		callback = function()
			local old_buf = state.buf

			state.job_id = nil
			state.is_open = false

			if state.win and vim.api.nvim_win_is_valid(state.win) then
				pcall(vim.api.nvim_win_close, state.win, false)
			end

			state.win = nil
			state.buf = nil

			cleanup_dead_terminal(old_buf)
		end,
	})
end

local function setup_bufleave_autocmd()
	if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
		return
	end

	vim.api.nvim_clear_autocmds({
		group = state.augroup,
		buffer = state.buf,
		event = "BufLeave",
	})

	vim.api.nvim_create_autocmd("BufLeave", {
		group = state.augroup,
		buffer = state.buf,
		once = true,
		callback = function()
			if state.win and vim.api.nvim_win_is_valid(state.win) then
				pcall(vim.api.nvim_win_close, state.win, false)
			end
			state.win = nil
			state.is_open = false
		end,
	})
end

function M.toggle()
	if state.is_open and state.win and vim.api.nvim_win_is_valid(state.win) then
		M.close()
		return
	end

	ensure_terminal()

	if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
		return
	end

	state.win = vim.api.nvim_open_win(state.buf, true, get_window_config())
	apply_highlights(state.win)
	setup_bufleave_autocmd()

	state.is_open = true
	vim.cmd("startinsert")
end

function M.close()
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		pcall(vim.api.nvim_win_close, state.win, false)
	end
	state.win = nil
	state.is_open = false
end

function M.exit()
	if state.job_id then
		vim.fn.chansend(state.job_id, "exit\n")
	else
		M.close()
	end
end

function M.kill()
	if state.job_id then
		vim.fn.jobstop(state.job_id)
	end

	if state.win and vim.api.nvim_win_is_valid(state.win) then
		pcall(vim.api.nvim_win_close, state.win, false)
	end

	if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
		pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
	end

	state.buf = nil
	state.win = nil
	state.job_id = nil
	state.is_open = false
end

vim.keymap.set("n", "<leader>tt", M.toggle, {
	noremap = true,
	silent = true,
	desc = "Toggle floating terminal",
})

vim.keymap.set("t", "<Esc>", function()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
	M.close()
end, {
	noremap = true,
	silent = true,
	desc = "Close floating terminal",
})

vim.keymap.set("t", "<C-q>", function()
	M.exit()
end, {
	noremap = true,
	silent = true,
	desc = "Exit floating terminal shell",
})

vim.keymap.set("n", "<leader>tq", function()
	M.exit()
end, {
	noremap = true,
	silent = true,
	desc = "Exit floating terminal shell",
})

vim.keymap.set("n", "<leader>tk", function()
	M.kill()
end, {
	noremap = true,
	silent = true,
	desc = "Kill floating terminal",
})

vim.api.nvim_create_user_command("FloatingTermToggle", function()
	M.toggle()
end, {})

vim.api.nvim_create_user_command("FloatingTermExit", function()
	M.exit()
end, {})

vim.api.nvim_create_user_command("FloatingTermKill", function()
	M.kill()
end, {})

return M
