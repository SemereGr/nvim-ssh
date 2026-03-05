return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			suggestion = { enabled = false },
			panel = { enabled = false },
			filetypes = {
				markdown = true,
				help = true,
			},
		},
	},
	{
		"NickvanDyke/opencode.nvim",
		dependencies = {
			{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
		},
		keys = {
			{
				"<leader>oa",
				function()
					require("opencode").ask()
				end,
			},
			{
				"<leader>a.",
				function()
					require("opencode").toggle()
				end,
				desc = "Toggle opencode",
			},
			{
				"<leader>oa",
				function()
					require("opencode").ask("@this: ")
				end,
				mode = "v",
			},
		},
	},
}
