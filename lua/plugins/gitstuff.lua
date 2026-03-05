return {
	-- for all git plugins
	{
		"tpope/vim-fugitive",
		config = function()
			vim.keymap.set("n", "<leader>gg", "<cmd>tabnew | Git | only<cr>", { desc = "Fugitive fullscreen tab" })

			local myFugitive = vim.api.nvim_create_augroup("myFugitive", {})

			local autocmd = vim.api.nvim_create_autocmd
			autocmd("BufWinEnter", {
				group = myFugitive,
				pattern = "*",
				callback = function()
					if vim.bo.ft ~= "fugitive" then
						return
					end

					local bufnr = vim.api.nvim_get_current_buf()
					local opts = { buffer = bufnr, remap = false }

					vim.keymap.set("n", "<leader>ghP", function()
						vim.cmd.Git("push")
					end, opts)

					-- NOTE: rebase always
					vim.keymap.set("n", "<leader>ghp", function()
						vim.cmd.Git({ "pull", "--rebase" })
					end, opts)

					-- NOTE: easy set up branch that wasn't setup properly
					vim.keymap.set("n", "<leader>ght", ":Git push -u origin ", opts)
				end,
			})
		end,
	},
	-- Lazy git
	{
		"kdheepak/lazygit.nvim",

		--NOTE: Trying out lazygit in Snacks nvim
		-- enabled = false,
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- window border thing
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- "nvim-telescope/telescope.nvim",
		},
		-- setting up with keys={} allows plugin to load when command runs at the start
		keys = {
			{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open lazy git" },
		},
	},
}
