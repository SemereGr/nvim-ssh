return {
	-- requires pngpaste ( brew install pngpaste )
	"HakonHarnes/img-clip.nvim",
	event = "VeryLazy",
	keys = {
		-- suggested keymap
		{ "<leader>pi", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },

		-- Use Neo-tree to open the file under the cursor
		vim.keymap.set("n", "<CR>", function()
			local buf = vim.api.nvim_get_current_buf()
			local file = vim.api.nvim_buf_get_name(buf)
			local ext = vim.fn.fnamemodify(file, ":e"):lower()

			-- If it's an image file, open it in Kitty (preview-style)
			if vim.tbl_contains({ "png", "jpg", "jpeg", "gif", "webp", "avif" }, ext) then
				vim.fn.jobstart({ "wezterm", "nvim", file })
				return
			end

			-- Otherwise, let Neo-tree handle the default open (folders/files)
			vim.cmd("NeoTreeExecute")
		end, { buffer = 0, desc = "Open image in Kitty or normal file" }),
	},
	opts = {
		default = {
			insert_mode_after_paste = true,
			url_encode_path = true,
			template = "$FILE_PATH",
			use_cursor_in_template = true,

			prompt_for_file_name = true,
			show_dir_path_in_prompt = true,

			use_absolute_path = false,
			relative_to_current_file = true,

			embed_image_as_base64 = false,
			max_base64_size = 10,

			dir_path = function()
				local cwd = vim.fn.getcwd()
				local vault_name = "Obsidian Vault" -- obsidian vault dir
				-- local vault_images_path = "D:\Obsidian Vault\images\"
				local vault_images_path = "/images/" --"/mnt/d/Obsidian Vault/images/"

				if cwd:match(vault_name) then
					return vault_images_path
				else
					return "assets"
				end
			end,

			drag_and_drop = {
				enabled = true,
				insert_mode = true,
				copy_images = true,
				download_images = true,
			},
		},
		-- add options here
		-- or leave it empty to use the default settings
	},
}
