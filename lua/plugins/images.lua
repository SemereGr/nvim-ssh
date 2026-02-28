return {
	"3rd/image.nvim",
	-- GitHub: https://github.com/3rd/image.nvim [web:188]
	event = "VeryLazy",
	-- Optional: you can also use hologram.nvim; this example uses image.nvim.
	-- 'edluffy/hologram.nvim', event = 'VeryLazy';

	-- `opts` work for image.nvim; if you use hologram.nvim, replace with `opts = { ... }`
	opts = {
		backend = "kitty", -- or 'wezterm' or 'wezterm', 'kitty', 'iterm2', 'sixel'
		max_width = nil,
		max_height = nil,
		max_width_window = 0.9,
		max_height_window = 0.9,
		dblclick_delay = 600,
		border = "none", -- or 'single', 'double', 'rounded'
		use_image_magic = true,
		cache_from_key = false,
		event = "UIEnter",
		-- Only auto‑render images when you are focused on the editor
		editor_only_render_when_focused = true,
		-- Auto‑render images in Markdown files
		markdown_filetypes = { "markdown", "md" },
		-- Auto‑show images when you open an image file directly (optional)
		hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
	},
}
