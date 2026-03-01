-- ~/.config/nvim/lua/plugins/fterm.lua
return {
	{
		"numToStr/FTerm.nvim",
		config = function()
			local FTerm = require("FTerm")

			-- Pretty + smaller by default
			local dims = { height = 0.55, width = 0.65, x = 0.5, y = 0.5 }

			local function apply()
				FTerm.setup({
					border = "rounded",
					hl = "NormalFloat",
					blend = 10, -- transparency via winblend
					dimensions = dims,
				})
			end
			apply()

			-- Base terminal
			vim.keymap.set("n", "<leader>tt", function()
				FTerm.toggle()
			end, { desc = "[T]oggle [T]erminal", silent = true })

			vim.keymap.set(
				"t",
				"<leader>tt",
				[[<C-\><C-n><CMD>lua require("FTerm").toggle()<CR>]],
				{ desc = "[T]oggle [T]erminal", silent = true }
			)

			-- Helpers: only try to open tools if installed
			local function toggle_cmd(cmd, ft, desc)
				return function()
					if vim.fn.executable(cmd) ~= 1 then
						vim.notify(
							("Missing command: %s (install it or remove the keymap)"):format(cmd),
							vim.log.levels.WARN
						)
						return
					end
					local term = FTerm:new({ ft = ft, cmd = cmd })
					term:toggle()
				end
			end

			vim.keymap.set(
				"n",
				"<leader>lg",
				toggle_cmd("lazygit", "fterm_lazygit", "lazygit"),
				{ desc = "Toggle [L]azy[G]it", silent = true }
			)
			vim.keymap.set(
				"t",
				"<leader>lg",
				[[<C-\><C-n><CMD>lua (function()
        local FTerm = require("FTerm")
        if vim.fn.executable("lazygit") ~= 1 then
          vim.notify("Missing command: lazygit", vim.log.levels.WARN); return
        end
        FTerm:new({ ft = "fterm_lazygit", cmd = "lazygit" }):toggle()
      end)()<CR>]],
				{ desc = "Toggle [L]azy[G]it", silent = true }
			)

			vim.keymap.set(
				"n",
				"<leader>tk",
				toggle_cmd("k9s", "fterm_k9s", "k9s"),
				{ desc = "[T]oggle [K]9s", silent = true }
			)
			vim.keymap.set(
				"t",
				"<leader>tk",
				[[<C-\><C-n><CMD>lua (function()
        local FTerm = require("FTerm")
        if vim.fn.executable("k9s") ~= 1 then
          vim.notify("Missing command: k9s", vim.log.levels.WARN); return
        end
        FTerm:new({ ft = "fterm_k9s", cmd = "k9s" }):toggle()
      end)()<CR>]],
				{ desc = "[T]oggle [K]9s", silent = true }
			)

			-- Resize (updates config; reopen the terminal to see the new size)
			local function bump(dh, dw)
				dims.height = math.max(0.25, math.min(0.95, dims.height + dh))
				dims.width = math.max(0.25, math.min(0.95, dims.width + dw))
				apply()
			end

			vim.keymap.set("n", "<leader>t+", function()
				bump(0.05, 0.05)
			end, { desc = "Terminal bigger" })
			vim.keymap.set("n", "<leader>t-", function()
				bump(-0.05, -0.05)
			end, { desc = "Terminal smaller" })
			vim.keymap.set("n", "<leader>tw", function()
				bump(0.00, 0.05)
			end, { desc = "Terminal wider" })
			vim.keymap.set("n", "<leader>tW", function()
				bump(0.00, -0.05)
			end, { desc = "Terminal narrower" })
			vim.keymap.set("n", "<leader>th", function()
				bump(0.05, 0.00)
			end, { desc = "Terminal taller" })
			vim.keymap.set("n", "<leader>tH", function()
				bump(-0.05, 0.00)
			end, { desc = "Terminal shorter" })
		end,
	},
}

-- return {
-- 	{
-- 		"numToStr/FTerm.nvim",
-- 		config = function()
-- 			local FTerm = require("FTerm")
--
-- 			-- Smaller by default (0..1). Tweak to taste.
-- 			vim.g.fterm_dims = { height = 0.6, width = 0.7, x = 0.5, y = 0.5 }
--
-- 			local function apply_dims()
-- 				FTerm.setup({
-- 					border = "single",
-- 					dimensions = vim.g.fterm_dims,
-- 				})
-- 			end
-- 			apply_dims()
--
-- 			-- Main floating shell
-- 			vim.keymap.set("n", "<leader>tt", function()
-- 				FTerm.toggle()
-- 			end, { desc = "[T]oggle [T]erminal", silent = true })
--
-- 			vim.keymap.set(
-- 				"t",
-- 				"<leader>tt",
-- 				[[<C-\><C-n><CMD>lua require("FTerm").toggle()<CR>]],
-- 				{ desc = "[T]oggle [T]erminal", silent = true }
-- 			)
--
-- 			-- Custom apps
-- 			local lazygit = FTerm:new({ ft = "fterm_lazygit", cmd = "lazygit" })
-- 			local k9s = FTerm:new({ ft = "fterm_k9s", cmd = "k9s" })
--
-- 			vim.keymap.set("n", "<leader>lg", function()
-- 				lazygit:toggle()
-- 			end, { desc = "Toggle [L]azy[G]it", silent = true })
-- 			vim.keymap.set(
-- 				"t",
-- 				"<leader>lg",
-- 				[[<C-\><C-n><CMD>lua require("FTerm").new({ ft="fterm_lazygit", cmd="lazygit" }):toggle()<CR>]],
-- 				{ desc = "Toggle [L]azy[G]it", silent = true }
-- 			)
--
-- 			vim.keymap.set("n", "<leader>tk", function()
-- 				k9s:toggle()
-- 			end, { desc = "[T]oggle [K]9s", silent = true })
-- 			vim.keymap.set(
-- 				"t",
-- 				"<leader>tk",
-- 				[[<C-\><C-n><CMD>lua require("FTerm").new({ ft="fterm_k9s", cmd="k9s" }):toggle()<CR>]],
-- 				{ desc = "[T]oggle [K]9s", silent = true }
-- 			)
--
-- 			-- “Resizable”: adjust dimensions, then re-open terminal to apply
-- 			local function bump(dh, dw)
-- 				local d = vim.g.fterm_dims
-- 				d.height = math.max(0.2, math.min(0.95, d.height + dh))
-- 				d.width = math.max(0.2, math.min(0.95, d.width + dw))
-- 				apply_dims()
-- 			end
--
-- 			vim.keymap.set("n", "<leader>t+", function()
-- 				bump(0.05, 0.05)
-- 			end, { desc = "Terminal bigger" })
-- 			vim.keymap.set("n", "<leader>t-", function()
-- 				bump(-0.05, -0.05)
-- 			end, { desc = "Terminal smaller" })
-- 			vim.keymap.set("n", "<leader>tw", function()
-- 				bump(0.00, 0.05)
-- 			end, { desc = "Terminal wider" })
-- 			vim.keymap.set("n", "<leader>tW", function()
-- 				bump(0.00, -0.05)
-- 			end, { desc = "Terminal narrower" })
-- 			vim.keymap.set("n", "<leader>th", function()
-- 				bump(0.05, 0.00)
-- 			end, { desc = "Terminal taller" })
-- 			vim.keymap.set("n", "<leader>tH", function()
-- 				bump(-0.05, 0.00)
-- 			end, { desc = "Terminal shorter" })
-- 		end,
-- 	},
-- }
