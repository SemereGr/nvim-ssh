return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	cmd = { "TSUpdate", "TSInstall", "TSInstallSync", "TSUninstall" },

	config = function()
		local ts = require("nvim-treesitter")

		-- Core languages that compile once at startup
		local fast_installed = {
			"lua",
			"python",
			"vim",
			"vimdoc",
			"bash",
			"javascript",
			"typescript",
			"json",
			"markdown",
			"markdown_inline",
			"html",
			"css",
			"gitattributes",
			"pbs",
		}
		pcall(ts.install, fast_installed, { summary = false })

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("kickstart_treesitter", { clear = true }),
			pattern = "*",
			callback = function(event)
				local lang = event.match
				local buftype = vim.bo[event.buf].buftype

				-- Skip UI buffers
				if buftype == "nofile" or buftype == "prompt" or buftype == "quickfix" then
					return
				end

				-- Skip plugin UI
				local ignored = { "lazy", "mason", "notify", "neotree", "NvimTree" }
				if vim.tbl_contains(ignored, lang) then
					return
				end

				-- Map Neovim filetypes to treesitter parsers
				local parser_mapping = {
					typescriptreact = "tsx",
					javascriptreact = "jsx",
				}
				local parser = parser_mapping[lang] or lang

				-- Only install languages that treesitter supports
				local ok, _ = pcall(vim.treesitter.minimum_version_required, parser)
				if not ok then
					return
				end

				-- Background install (for Java, Go, Terraform, …)
				pcall(ts.install, { parser }, { summary = false })

				-- Try highlighting; if parser not ready, it just fails silently
				pcall(vim.treesitter.start, event.buf, parser)

				-- Ruby special handling
				if lang == "ruby" then
					vim.bo[event.buf].syntax = "ruby"
				else
					vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
}
