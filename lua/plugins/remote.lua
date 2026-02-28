-- -- remote.lua
-- ~/.config/nvim/lua/plugins/remote.lua
local M = {}
local uv = vim.loop
local api = vim.api
local fn = vim.fn

-- Helper to create folder if it doesn't exist
local function ensure_dir(path)
	if fn.isdirectory(path) == 0 then
		fn.mkdir(path, "p")
	end
end

-- Mount a remote directory via SSHFS
local function mount_remote(host, remote_path, mount_point, port)
	port = port or 39099
	ensure_dir(mount_point)

	local cmd = {
		"sshfs",
		"-o",
		"reconnect",
		"-p",
		tostring(port),
		host .. ":" .. remote_path,
		mount_point,
	}

	uv.spawn(cmd[1], { args = { unpack(cmd, 2) } }, function(code, _signal)
		vim.schedule(function()
			if code == 0 then
				api.nvim_notify("Remote mounted: " .. host .. ":" .. remote_path, vim.log.levels.INFO, {})
			else
				api.nvim_notify(
					"Failed to mount: " .. host .. ":" .. remote_path .. " (code " .. code .. ")",
					vim.log.levels.ERROR,
					{}
				)
			end
		end)
	end)
end

-- Unmount via fusermount
local function unmount(mount_point)
	uv.spawn("fusermount", { args = { "-u", mount_point } }, function(code, _signal)
		vim.schedule(function()
			if code == 0 then
				api.nvim_notify("Unmounted: " .. mount_point, vim.log.levels.INFO, {})
			else
				api.nvim_notify(
					"Failed to unmount: " .. mount_point .. " (code " .. code .. ")",
					vim.log.levels.ERROR,
					{}
				)
			end
		end)
	end)
end

-- Interactive prompt to mount remote
function M.prompt_mount()
	vim.ui.input({ prompt = "Host (user@host): " }, function(host)
		if not host or #host == 0 then
			return
		end
		vim.ui.input({ prompt = "Remote path: " }, function(remote_path)
			if not remote_path or #remote_path == 0 then
				return
			end
			vim.ui.input({ prompt = "Local mount point (default ~/.local/share/remote): " }, function(local_path)
				local mount_point = local_path and #local_path > 0 and local_path
					or fn.expand("~/.local/share/remote/" .. host:gsub("[^%w]", "_"))
				mount_remote(host, remote_path, mount_point)
			end)
		end)
	end)
end

-- Interactive prompt to unmount
function M.prompt_unmount()
	vim.ui.input({ prompt = "Local mount point to unmount: " }, function(local_path)
		if local_path and #local_path > 0 then
			unmount(local_path)
		end
	end)
end

-- Direct mount function
function M.mount(host, remote_path, port)
	local mount_point = fn.expand("~/.local/share/remote/" .. host:gsub("[^%w]", "_"))
	mount_remote(host, remote_path, mount_point, port)
end

-- Direct unmount function
function M.unmount(host)
	local mount_point = fn.expand("~/.local/share/remote/" .. host:gsub("[^%w]", "_"))
	unmount(mount_point)
end

-- Setup keymaps
function M.setup()
	vim.keymap.set("n", "<leader>cf", M.prompt_mount, { desc = "Mount SSHFS remote" })
	vim.keymap.set("n", "<leader>cu", M.prompt_unmount, { desc = "Unmount SSHFS remote" })
end

return M
